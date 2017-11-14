require "date"
require "nokogiri"
require "htmlentities"

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
        if node.respond_to?(:lineno) 
            warn %(asciidoctor: WARNING (#{node.lineno}): converter missing for #{name || node.node_name} node in RFC backend)
        else 
          warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        end
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

      # TODO: dead code? remove.
      # def authorname(node, suffix)
      #   noko do |xml|
      #     author_attributes = {
      #       fullname: node.attr("author#{suffix}") || node.attr("fullname#{suffix}"),
      #       surname: node.attr("lastname#{suffix}"),
      #       initials: node.attr("forename_initials#{suffix}"),
      #       role: node.attr("role#{suffix}"),
      #     }.reject { |_, value| value.nil? }
      #     xml.author **author_attributes
      #   end
      # end

      # Syntax:
      #   = Title
      #   Author
      #   :area x, y
      def area(node, xml)
        node.attr("area")&.split(/, ?/)&.each do |ar|
          xml.area { |a| a << ar }
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node, xml)
        node.attr("workgroup")&.split(/, ?/)&.each do |wg|
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
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}) if terms.size > 2
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
          warn %(asciidoctor: WARNING (#{node.lineno}): references are not raw XML: #{node.context})
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

      #def dash(camel_cased_word)
      #  camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
      #end

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
            if node.respond_to?(:context) && (node.context == :literal || node.context == :listing)
              result << x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
            else
              # strip not only HTML tags <tag>, but also Asciidoc crossreferences <<xref>>
              result << x.gsub(/<[^>]*>+/, "")
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
    end
  end
end
