# coding: utf-8

module Asciidoctor
  module RFC::V3
    module Base
      # Syntax:
      #   =Title
      #   Author
      #   :ipr
      #   :obsoletes
      #   :updates
      #   :submissionType
      #   :indexInclude
      #   :iprExtract
      #   :sortRefs
      #   :symRefs
      #   :tocInclude
      #   :tocDepth
      #
      #   ABSTRACT
      #
      #   NOTEs
      #
      #   ==first title
      #   CONTENT
      #
      #   [bibliography] # start of back matter
      #   == Bibliography
      #
      #   [appendix] # start of back matter if not already started
      #   == Appendix
      def document(node)
        $seen_back_matter = false
        # If this is present, then BCP14 keywords in boldface are not assumed to be <bcp14> tags. By default they are.
        $bcp_bold = !(node.attr? "no-rfc-bold-bcp14")
        $smart_quotes = (node.attr("smart-quotes") != "false")
        $xreftext = {}
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'

        t = Time.now.getutc
        preptime = sprintf(
          "%04d-%02d-%02dT%02d:%02d:%02dZ",
          t.year, t.month, t.day, t.hour, t.min, t.sec
        )

        rfc_attributes = {
          ipr:            node.attr("ipr"),
          obsoletes:      node.attr("obsoletes"),
          updates:        node.attr("updates"),
          indexInclude:   node.attr("index-include"),
          iprExtract:     node.attr("ipr-extract"),
          sortRefs:       node.attr("sort-refs"),
          symRefs:        node.attr("sym-refs"),
          tocInclude:     node.attr("toc-include"),
          tocDepth:       node.attr("toc-depth"),
          submissionType: node.attr("submission-type") || "IETF",
          'xml:lang':     node.attr("xml-lang"),
          prepTime:       preptime,
          version:        "3",
          'xmlns:xi':        "http://www.w3.org/2001/XInclude",
        }

        rfc_open = noko { |xml| xml.rfc **attr_code(rfc_attributes) }.join.gsub(/\/>$/, ">")
        result << rfc_open

        result << (link node)

        result << noko { |xml| front node, xml }
        result.last.last.gsub! /<\/front>$/, "" # FIXME: this is a hack!
        result << "</front><middle1>"

        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        result = result.flatten
        result = if result.any? { |e| e =~ /<\/front><middle>/ } && result.any? { |e| e =~ /<\/front><middle1>/ }
                   result.reject { |e| e =~ /<\/front><middle1>/ }
                 else
                   result.map { |e| e =~ /<\/front><middle1>/ ? "</front><middle>" : e }
                 end
        ret = result * "\n"
        ret = cleanup(ret)
        ret1 = Nokogiri::XML(ret)
        ret1 = set_pis(node, ret1)
        Validate::validate(ret1)
        ret1 = resolve_references(node, ret1)
        # Validate::validate(ret1)
        ret1
      end

      def resolve_references(node, doc)
        extract_entities(node, doc).each do |entity|
          # TODO actual XML
          entity[:node].replace("<xi:include href='#{entity[:url]}' parse='text'/>")
        end
        doc
      end

      # Syntax:
      #   = Title
      #   Author
      #   :link href,href rel
      def link(node)
        result = []
        result << noko do |xml|
          links = (node.attr("link") || "").split(/,\s*/)
          links.each do |link|
            matched = /^(?<href>\S+)\s+(?<rel>\S+)$/.match link
            link_attributes = {
              href: matched.nil? ? link : matched[:href],
              rel: matched.nil? ? nil : matched[:rel],
            }
            xml.link **attr_code(link_attributes)
          end
        end
        result
      end

      def inline_break(node)
        # <br> is only defined within tables
        noko do |xml|
          xml << node.text
          xml.br if node.parent.context == :cell
        end.join
      end

      BCP_KEYWORDS = [
        "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
        "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", "OPTIONAL"
      ].freeze

      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis then xml.em node.text
          when :strong
            if $bcp_bold && BCP_KEYWORDS.include?(node.text)
              xml.bcp14 node.text
            else
              xml.strong node.text
            end
          when :monospaced then xml.tt node.text
          when :double
            xml << ($smart_quotes ? "“#{node.text}”" : "\"#{node.text}\"")
          when :single
            xml << ($smart_quotes ? "‘#{node.text}’" : "'#{node.text}'")
          when :superscript then xml.sup node.text
          when :subscript then xml.sub node.text
          else
            # [bcp14]#MUST NOT#
            if node.role == "bcp14"
              xml.bcp14 node.text.upcase
            else
              xml << node.text
            end
          end
        end.join
      end

      # Syntax:
      #   [[id]]
      #   [keepWithNext=true,keepWithPrevious=true] (optional)
      #   Text
      def paragraph(node)
        result = []

        t_attributes = {
          anchor: node.id,
          keepWithNext: node.attr("keep-with-next"),
          keepWithPrevious: node.attr("keep-with-previous"),
        }

        result << noko do |xml|
          xml.t **attr_code(t_attributes) do |xml_t|
            xml_t << node.content
          end
        end

        result
      end

      # Syntax:
      #   :sectnums: (toggle)
      #   :sectnums!: (toggle)
      #   [[id]]
      #   [removeInRFC=true,toc=include|exclude|default] (optional)
      #   == title
      #   Content
      #
      #   [[id]]
      #   [bibliography]
      #   == Normative|Informative References
      #   * [[[ref1]]] Ref [must provide references as list]
      #   * [[[ref2]]] Ref
      def section(node)
        result = []
        if node.attr("style") == "bibliography" ||
            node.parent.context == :section && node.parent.attr("style") == "bibliography"
          $processing_reflist = true

          references_attributes = {
            anchor: node.id,
          }

          node.blocks.each do |block|
            if block.context == :section
              result << section(block)
            elsif block.context == :pass
              # we are assuming a single contiguous :pass block of XML
              result << noko do |xml|
                xml.references **references_attributes do |xml_references|
                  xml_references.name node.title unless node.title.nil?
                  # xml_references << reflist(block).join("\n")
                  # NOTE: we're allowing the user to do more or less whathever
                  #   in the passthrough since the xpath below just fishes out ALL
                  #   <reference>s in an unrooted fragment, regardless of structure.
                  Nokogiri::XML::DocumentFragment.
                    parse(block.content).xpath(".//reference").
                    each { |reference| xml_references << reference.to_xml }
                end
              end
            elsif block.context == :ulist
              block.items.each do |i|
                i.text # we only process the item for its displayreferences
              end
            end
          end

          unless $xreftext.empty? || $seen_back_matter
            result = result.unshift($xreftext.keys.map { |k| %(<displayreference target="#{k}" to="#{$xreftext[k]}"/>) })
          end
          result = result.unshift("</middle><back>") unless $seen_back_matter
          $processing_reflist = false
          $seen_back_matter = true
        else
          if node.attr("style") == "appendix"
            result << "</middle><back>" unless $seen_back_matter
            $seen_back_matter = true
          end

          section_attributes = {
            anchor: node.id,
            removeInRFC: node.attr("remove-in-rfc"),
            toc: node.attr("toc"),
            numbered: node.attr?("sectnums"),
          }

          result << noko do |xml|
            xml.section **attr_code(section_attributes) do |section_xml|
              section_xml.name { |name| name << node.title } unless node.title.nil?
              section_xml << node.content
            end
          end
        end
        result
      end

      # Syntax:
      #   [[id]]
      #   .Name
      #   [link=xxx,align=left|center|right,alt=alt_text,type]
      #   image::filename[alt,width,height]
      # @note ignoring width, height attributes
      def image(node)
        uri = node.image_uri node.attr("target")
        artwork_attributes = {
          align: node.attr("align"),
          alt: node.alt,
          anchor: node.id,
          height: node.attr("height"),
          name: node.title,
          src: uri,
          type: (uri =~ /\.svg$/ ? "svg" : "binary-art"),
          width: node.attr("width"),
        }

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.artwork **attr_code(artwork_attributes)
            end
          else
            xml.artwork **attr_code(artwork_attributes)
          end
        end
      end

      # clean up XML
      def cleanup(doc)
        xmldoc = Nokogiri::XML(doc)
        crefs = xmldoc.xpath("//cref")
        # any crefs that are direct children of section should become children of the preceding
        # paragraph, if it exists; otherwise, they need to be wrapped in a paragraph
        crefs.each do |cref|
          if cref.parent.name == "section"
            prev = cref.previous_element
            if !prev.nil? && prev.name == "t"
              cref.parent = prev
            else
              t = Nokogiri::XML::Element.new("t", xmldoc)
              cref.before(t)
              cref.parent = t
            end
          end
        end
        unless $smart_quotes
          xmldoc.traverse do |node|
            if node.text?
              node.content = node.content.tr("\u2019", "'")
              node.content = node.content.gsub(/\&#8217;/, "'")
              node.content = node.content.gsub(/\&#x2019;/, "'")
            elsif node.element?
              node.attributes.each do |k, v|
                node.set_attribute(k, v.content.tr("\u2019", "'"))
                node.set_attribute(k, v.content.gsub(/\&#8217;/, "'"))
                node.set_attribute(k, v.content.gsub(/\&#x2019;/, "'"))
              end
            end
          end
        end

        xmldoc.to_xml(encoding: "US-ASCII")
      end
    end
  end
end
