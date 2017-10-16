module Asciidoctor
  module RFC::V2
    module Base
      # Syntax:
      #   =Title
      #   Author
      #   :status
      #   :consensus
      #   :name
      #   :number
      #
      #   :ipr
      #   :obsoletes
      #   :updates
      #   :submissionType
      #   :indexInclude
      #   :ipr-extract
      #   :sort-refs
      #   :sym-refs
      #   :toc-include
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
        $seen_abstract = false
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'

        is_rfc = node.attr("doctype") == "rfc"

        consensus_value = {
          "false" => "no",
          "true" => "yes",
        }[node.attr("consensus")] || node.attr("consensus")

        rfc_attributes = {
          ipr:            node.attr("ipr"),
          obsoletes:      node.attr("obsoletes"),
          updates:        node.attr("updates"),
          category:       node.attr("status"),
          consensus:      consensus_value,
          submissionType: node.attr("submission-type") || "IETF",
          iprExtract:     node.attr("ipr-extract"),
          docName:        (node.attr("name") unless is_rfc),
          number:         (node.attr("name") if is_rfc),
          seriesNo:       node.attr("series-no"),
          'xml:lang':     node.attr("xml-lang"),
        }.reject { |_, value| value.nil? }

        rfc_open = noko { |xml| xml.rfc **rfc_attributes }.join.gsub(/\/>$/, ">")
        result << rfc_open

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
        Validate::validate(ret)
        ret
      end

      def inline_break(node)
        noko do |xml|
          xml << node.text
          xml.vspace
        end.join
      end

      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis
            xml.spanx node.text, style: "emph"
          when :strong
            xml.spanx node.text, style: "strong"
          when :monospaced
            xml.spanx node.text, style: "verb"
          when :double
            xml << "\"#{node.text}\""
          when :single
            xml << "'#{node.text}'"
          when :superscript
            xml << "^#{node.text}^"
          when :subscript
            xml << "_#{node.text}_"
          else
            # [bcp14]#MUST NOT#
            if node.role == "bcp14"
              xml.spanx node.text.upcase, style: "strong"
            else
              xml << node.text
            end
          end
        end.join
      end

      # Syntax:
      #   [[id]]
      #   Text
      def paragraph(node)
        result = []

        if (node.parent.context == :preamble) && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        t_attributes = {
          anchor: node.id,
        }.reject { |_, value| value.nil? }

        result << noko do |xml|
          xml.t **t_attributes do |xml_t|
            xml_t << node.content
          end
        end

        result
      end

      def verse(node)
        result = []

        if (node.parent.context == :preamble) && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        t_attributes = {
          anchor: node.id,
        }.reject { |_, value| value.nil? }

        result << noko do |xml|
          xml.t **t_attributes do |xml_t|
            xml_t << node.content.gsub("\n", "<br/>")
          end
        end

        result
      end

      # Syntax:
      #   [[id]]
      #   == title
      #   Content
      #
      #   [bibliography]
      #   == Normative|Informative References
      #   * [[[ref1]]] Ref [must provide references as list]
      #   * [[[ref2]]] Ref
      def section(node)
        result = []
        if node.attr("style") == "bibliography"
          $xreftext = {}
          $processing_reflist = true

          references_attributes = {
            title: node.title,
          }.reject { |_, value| value.nil? }

          result << noko do |xml|
            xml.references **references_attributes do |xml_references|
              node.blocks.each { |b| xml_references << reflist(b).join }
            end
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
            title: node.title,
          }.reject { |_, value| value.nil? }

          result << noko do |xml|
            xml.section **section_attributes do |xml_section|
              xml_section << node.content
            end
          end
        end
        result
      end

      # Syntax:
      #   [[id]]
      #   .Name
      #   [link=xxx,align=left|center|right,alt=alt_text,type]
      #   image::filename[alt_text,width,height]
      # @note ignoring width, height attributes
      def image(node)
        uri = node.image_uri node.attr("target")
        artwork_attributes = {
          align: node.attr("align"),
          alt: node.alt,
          height: node.attr("height"),
          name: node.title,
          src: uri,
          type: node.attr("type"),
          width: node.attr("width"),
        }.reject { |_, value| value.nil? }

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.artwork **artwork_attributes
            end
          else
            xml.artwork **artwork_attributes
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
        xmldoc.to_s
      end
    end
  end
end
