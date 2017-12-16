require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "set"

module Asciidoctor
  module RFC::Common
    module Base
      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def document_ns_attributes(_doc)
        # ' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        warn %(asciidoctor: WARNING (#{current_location(node)}): converter missing for #{name || node.node_name} node in RFC backend)
        nil
      end

      # Syntax:
      #   = Title
      #   Author
      #   :HEADER
      #
      #   ABSTRACT
      #
      #   NOTE: note
      #
      # @note (boilerplate is ignored)
      def preamble(node)
        result = []

        # NOTE: *list is V3, verse is V2, paragraph is both
        abstractable_contexts = %i{paragraph dlist olist ulist verse open}

        abstract_blocks = node.blocks.take_while do |block|
          abstractable_contexts.include? block.context
        end

        remainder_blocks = node.blocks[abstract_blocks.length..-1]

        result << noko do |xml|
          if abstract_blocks.any?
            xml.abstract do |xml_abstract|
              xml_abstract << abstract_blocks.map(&:render).flatten.join("\n")
            end
          end
          xml << remainder_blocks.map(&:render).flatten.join("\n")
        end

        result << "</front><middle>"
        result
      end

      IETF_AREAS = ["art", "Applications and Real-Time",
                    "gen", "General",
                    "int", "Internet",
                    "ops", "Operations and Management",
                    "rtg", "Routing",
                    "sec", "Security",
                    "tsv", "Transport"].freeze

      # Syntax:
      #   = Title
      #   Author
      #   :area x, y
      def area(node, xml)
        node.attr("area")&.split(/, ?/)&.each do |ar|
          if ar =~ / Area$/i
            warn %(asciidoctor: WARNING (#{current_location(node)}): stripping suffix "Area" from area #{ar})
            ar = ar.gsub(/ Area$/i, "")
          end
          warn %(asciidoctor: WARNING (#{current_location(node)}): unrecognised area #{ar}) unless IETF_AREAS.include?(ar)
          xml.area { |a| a << ar }
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node, xml)
        workgroups = cache_workgroup(node)
        node.attr("workgroup")&.split(/, ?/)&.each do |wg|
          if wg =~ / (Working Group)$/i
            warn %(asciidoctor: WARNING (#{current_location(node)}): suffix "Working Group" will be stripped in published RFC from #{wg})
            wg_norm = wg.gsub(/ Working Group$/i, "")
          end
          if wg =~ / (Research Group)$/i
            warn %(asciidoctor: WARNING (#{current_location(node)}): suffix "Research Group" will be stripped from working group #{wg})
            wg_norm = wg.gsub(/ Research Group$/i, "")
          end
          warn %(asciidoctor: WARNING (#{current_location(node)}): unrecognised working group #{wg}) unless workgroups.include?(wg_norm)
          xml.workgroup { |w| w << wg }
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :keyword x, y
      def keyword(node, xml)
        node.attr("keyword")&.split(/, ?/)&.each do |kw|
          xml.keyword { |k| k << kw }
        end
      end

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          t_attributes = {
            anchor: node.id,
          }
          result << noko { |xml| xml.t result1, **attr_code(t_attributes) }
        end
        result
      end

      def inline_indexterm(node)
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible
          iref_attributes = {
            item: node.text,
          }
          node.text + noko { |xml| xml.iref **attr_code(iref_attributes) }.join
        else
          terms = node.attr "terms"
          warn %(asciidoctor: WARNING (#{current_location(node)}): only primary and secondary index terms supported: #{terms.join(': ')}) if terms.size > 2
          iref_attributes = {
            item: terms[0],
            subitem: (terms.size > 1 ? terms[1] : nil),
          }
          noko { |xml| xml.iref **attr_code(iref_attributes) }.join
        end
      end

      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        result = []
        if node.context == :pass
          node.lines.each do |item|
            # undo XML substitution
            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
            result << ref
          end
        else
          warn %(asciidoctor: WARNING (#{current_location(node)}): references are not raw XML: #{node.context})
        end
        result
      end

      def open(node)
        # open block is a container of multiple blocks, treated as a single block.
        # We append each contained block to its parent
        result = []
        if node.blocks?
          node.blocks.each do |b|
            result << send(b.context, b)
          end
        else
          result = paragraph(node)
        end
        result
      end

      # def dash(camel_cased_word)
      #  camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
      # end

      def common_rfc_pis(node)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use, common to v2 and v3.
        # These are set only if explicitly specified, with the exception
        # of compact and subcompact
        rfc_pis = {
          artworkdelimiter: node.attr("artworkdelimiter"),
          artworklines: node.attr("artworklines"),
          authorship: node.attr("authorship"),
          autobreaks: node.attr("autobreaks"),
          background: node.attr("background"),
          colonspace: node.attr("colonspace"),
          comments: node.attr("comments"),
          docmapping: node.attr("docmapping"),
          editing: node.attr("editing"),
          emoticonic: node.attr("emoticonic"),
          footer: node.attr("footer"),
          header: node.attr("header"),
          inline: node.attr("inline"),
          iprnotified: node.attr("iprnotified"),
          linkmailto: node.attr("linkmailto"),
          linefile: node.attr("linefile"),
          notedraftinprogress: node.attr("notedraftinprogress"),
          private: node.attr("private"),
          refparent: node.attr("refparent"),
          rfcedstyle: node.attr("rfcedstyle"),
          slides: node.attr("slides"),
          "text-list-symbols": node.attr("text-list-symbols"),
          tocappendix: node.attr("tocappendix"),
          tocindent: node.attr("tocindent"),
          tocnarrow: node.attr("tocnarrow"),
          tocompact: node.attr("tocompact"),
          topblock: node.attr("topblock"),
          useobject: node.attr("useobject"),

          # give errors regarding ID-nits and DTD validation
          strict: node.attr("strict") || "yes",

          # Vertical whitespace control
          # (using these PIs as follows is recommended by the RFC Editor)

          # do not start each main section on a new page
          compact: node.attr("compact") || "yes",
          # keep one blank line between list items
          subcompact: node.attr("subcompact") || "no",

          # TOC control
          # generate a ToC
          toc: node.attr("toc-include") == "false" ? "no" : "yes",

          # the number of levels of subsections in ToC. default: 3
          tocdepth: node.attr("toc-depth") || "4",

          # use anchors rather than numbers for references
          symrefs: node.attr("sym-refs") || "yes",
          # sort references
          sortrefs: node.attr("sort-refs") || "yes",
        }

        attr_code(rfc_pis)
      end

      def set_pis(node, doc)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use. (Here they are set differently than
        # their defaults in xml2rfc v1.32)

        if node.attr("rfc2629xslt") != "false"
          pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet",
                                                        'type="text/xsl" href="rfc2629.xslt"')
          doc.root.add_previous_sibling(pi)
        end

        doc.create_internal_subset("rfc", nil, "rfc2629.dtd")
        rfc_pis = common_rfc_pis(node)
        rfc_pis.each_pair do |k, v|
          pi = Nokogiri::XML::ProcessingInstruction.new(doc,
                                                        "rfc",
                                                        "#{k}=\"#{v}\"")
          doc.root.add_previous_sibling(pi)
        end

        doc
      end

      # extract references which can be expressed as externally defined entities
      def extract_entities(node, xmldoc)
        refs = xmldoc.xpath("//reference")
        ret = []
        biblio = cache_biblio(node)
        refs.each do |ref|
          next if ref.parent.name == "referencegroup"
          id = ref.at('.//seriesInfo[@name="Internet-Draft"]')
          anchor = ref["anchor"]
          url = if id.nil?
                  biblio[anchor]
                else
                  biblio["I-D.#{id['value']}"] # the specific version reference
                end
          if biblio.has_key? anchor
            ret << { entity: anchor,
                     node: ref,
                     url: url }
          end
        end
        ret
      end

      # if node contains blocks, flatten them into a single line
      def flatten(node)
        result = []
        result << node.text if node.respond_to?(:text)
        if node.blocks?
          node.blocks.each { |b| result << flatten(b) }
        else
          result << node.content
        end
        result.reject(&:empty?)
      end

      # if node contains blocks, flatten them into a single line; and extract only raw text
      def flatten_rawtext(node)
        result = []
        if node.respond_to?(:blocks) && node.blocks?
          node.blocks.each { |b| result << flatten_rawtext(b) }
        elsif node.respond_to?(:lines)
          node.lines.each do |x|
            result << if node.respond_to?(:context) && (node.context == :literal || node.context == :listing)
                        x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
                      else
                        # strip not only HTML tags <tag>, but also Asciidoc crossreferences <<xref>>
                        x.gsub(/<[^>]*>+/, "")
                      end
          end
        elsif node.respond_to?(:text)
          result << node.text.gsub(/<[^>]*>+/, "")
        else
          result << node.content.gsub(/<[^>]*>+/, "")
        end
        result.reject(&:empty?)
      end

      # block for processing XML document fragments as XHTML, to allow for HTMLentities
      def noko(&block)
        # fragment = ::Nokogiri::XML::DocumentFragment.parse("")
        # fragment.doc.create_internal_subset("xml", nil, "xhtml.dtd")
        head = <<HERE
        <!DOCTYPE html SYSTEM
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <title></title>
        <meta charset="UTF-8" />
        </head>
        <body>
        </body>
        </html>
HERE
        doc = ::Nokogiri::XML.parse(head)
        fragment = doc.fragment("")
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml(encoding: "US-ASCII").lines.map { |l| l.gsub(/\s*\n/, "") }
      end

      def attr_code(attributes)
        attributes = attributes.reject { |_, val| val.nil? }.map
        attributes.map do |k, v|
          [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
        end.to_h
      end

      def current_location(node)
        return "Line #{node.lineno}" if node.respond_to?(:lineno) && !node.lineno.nil? && !node.lineno.empty?
        return "ID #{node.id}" if node.respond_to?(:id) && !node.id.nil?
        while !node.nil? && (!node.respond_to?(:level) || node.level > 0) && node.context != :section
          node = node.parent
          return "Section: #{node.title}" if !node.nil? && node.context == :section
        end
        "??"
      end

      def cache_workgroup(node)
        wgcache_name = "#{Dir.home}/.asciidoc-rfc-workgroup-cache.json"
        # If we are required to, clear the wg cache
        if node.attr("flush-caches") == "true"
          system("rm -f #{wgcache_name}")
        end
        # Is there already a wg cache? If not, create it.
        wg = []
        if Pathname.new(wgcache_name).file?
          File.open(wgcache_name, "r") do |f|
            wg = JSON.parse(f.read)
          end
        else
          File.open(wgcache_name, "w") do |b|
            STDERR.puts "Reading workgroups from https://tools.ietf.org/wg/..."
            Kernel.open("https://tools.ietf.org/wg/") do |f|
              f.each_line do |line|
                line.scan(%r{<td width="50%" style='padding: 0 1ex'>([^<]+)</td>}) do |w|
                  wg << w[0].gsub(/\s+$/, "").gsub(/ Working Group$/, "")
                end
              end
            end
            STDERR.puts "Reading workgroups from https://irtf.org/groups..."
            Kernel.open("https://irtf.org/groups", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |f|
              f.each_line do |line|
                line.scan(%r{<a title="([^"]+) Research Group"[^>]+>([^<]+)<}) do |w|
                  wg << w[0].gsub(/\s+$/, "")
                  wg << w[1].gsub(/\s+$/, "") # abbrev
                end
              end
            end
            b << wg.to_json
          end
        end
        wg
      end

      def cache_biblio(node)
        bibliocache_name = "#{Dir.home}/.asciidoc-rfc-biblio-cache.json"
        # If we are required to, clear the biblio cache
        if node.attr("flush-caches") == "true"
          system("rm -f #{bibliocache_name}")
        end
        # Is there already a biblio cache? If not, create it.
        biblio = {}
        if Pathname.new(bibliocache_name).file?
          File.open(bibliocache_name, "r") do |f|
            biblio = JSON.parse(f.read)
          end
        else
          File.open(bibliocache_name, "w") do |b|
            STDERR.puts "Reading references from https://xml2rfc.tools.ietf.org/public/rfc/bibxml/..."
            Kernel.open("https://xml2rfc.tools.ietf.org/public/rfc/bibxml/") do |f|
              # I'm just working off the ls output
              f.each_line do |line|
                line.scan(/a href="reference.RFC.(\d+).xml">/) do |w|
                  biblio["RFC#{w[0]}"] = "https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.#{w[0]}.xml"
                end
              end
              ["https://xml2rfc.tools.ietf.org/public/rfc/bibxml2/",
               "https://xml2rfc.tools.ietf.org/public/rfc/bibxml3/",
               "https://xml2rfc.tools.ietf.org/public/rfc/bibxml4/",
               "https://xml2rfc.tools.ietf.org/public/rfc/bibxml5/"].each do |url|
                 STDERR.puts "Reading references from #{url}..."
                 Kernel.open(url) do |f1|
                   f1.each_line do |line|
                     line.scan(/a href="reference.(\S+).xml">/) do |w|
                       biblio[w[0]] = "#{url}/reference.#{w[0]}.xml"
                     end
                   end
                 end
               end
            end
            b << biblio.to_json
          end
        end
        biblio
      end

      # insert bibliography based on anchors, references directory, and list of normatives in doc attribute
      def insert_biblio(node, xmldoc)
        # we want no references in this document, so we can ignore any anchors of references
        xmldoc.xpath("//referencegroup").each(&:remove)
        xmldoc.xpath("//reference").each(&:remove)
        refs = Set.new
        xmldoc.xpath("//xref").each { |r| refs << r["target"] }
        xmldoc.xpath("//relref").each { |r| refs << r["target"] }
        anchors = Set.new
        # we have no references in this document, so any remaining anchors are internal cross-refs only
        xmldoc.xpath("//@anchor").each { |r| anchors << r.value }
        refs = refs - anchors

        norm_refs_spec = Set.new(node.attr("normative").split(/,[ ]?/))
        norm_refs = refs.intersection(norm_refs_spec)
        info_refs = refs - norm_refs
        seen_norm_refs = Set.new
        seen_info_refs = Set.new
        norm_refxml_in = {}
        info_refxml_in = {}
        norm_refxml_out = []
        info_refxml_out = []

        bibliodir = node.attr("biblio-dir")
        Dir.foreach bibliodir do |f|
          next if [".", ".."].include? f
          text = File.read("#{bibliodir}/#{f}", encoding: "utf-8")
          next unless text =~ /<reference/
          text =~ /<reference[^>]*anchor=['"]([^'"]*)/
          anchor = Regexp.last_match(1)
          next if anchor.nil? || anchor.empty?
          if norm_refs.include?(anchor)
            norm_refxml_in[anchor] = text
            seen_norm_refs << anchor
          else
            info_refxml_in[anchor] = text
            seen_info_refs << anchor
          end
        end

        biblio = cache_biblio(node)
        norm_refs.each do |r|
          if norm_refxml_in.has_key?(r)
            # priority to on-disk references over skeleton references: they may contain draft information
            norm_refxml_out << norm_refxml_in[r]
          elsif biblio.has_key?(r)
            norm_refxml_out << %{<reference anchor="#{r}"/>}
          else
            warn "Reference #{r} has not been includes in references directory, and is not a recognised external RFC reference"
          end
        end
        info_refs.each do |r|
          if info_refxml_in.has_key?(r)
            info_refxml_out << info_refxml_in[r]
          elsif biblio.has_key?(r)
            info_refxml_out << %{<reference anchor="#{r}"/>}
          else
            warn "Reference #{r} has not been includes in references directory, and is not a recognised external RFC reference"
          end
        end

        xml_location = xmldoc.at('//references[@title="Normative References" or name="Normative References"]')
        xml_location&.children = Nokogiri::XML.fragment(norm_refxml_out.join)
        xml_location = xmldoc.at('//references[@title="Informative References" or name="Informative References"]')
        xml_location&.children = Nokogiri::XML.fragment(info_refxml_out.join)
        xmldoc
      end
    end
  end
end
