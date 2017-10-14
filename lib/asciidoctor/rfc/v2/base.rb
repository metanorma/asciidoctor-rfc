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
        doctype = node.attr "doctype"
        is_rfc = (doctype == "rfc")
        category = set_header_attribute "category", node.attr("status")
        consensus_value = node.attr("consensus")
        consensus_value  = "no" if consensus_value == "false"
        consensus_value  = "yes" if consensus_value == "true"
        consensus = set_header_attribute "consensus", consensus_value
        if is_rfc
          number = set_header_attribute "number", node.attr("name")
        else
          docName = set_header_attribute "docName", node.attr("name")
        end
        ipr = get_header_attribute node, "ipr"
        iprExtract = get_header_attribute node, "iprExtract"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        seriesNo = get_header_attribute node, "seriesNo"
        submissionType = get_header_attribute node, "submissionType", "IETF"
        xmllang = set_header_attribute "xml:lang", node.attr("xml-lang")

        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{category}
        #{consensus}#{submissionType}#{iprExtract}#{docName}#{number}#{seriesNo}#{xmllang}>)

        result << noko { |xml| front node, xml }
        result.last.last.gsub! /<\/front>$/, "" # FIXME: this is a hack!
        result << "</front><middle1>"

        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        result = result.flatten
        if result.any? { |e| e =~ /<\/front><middle>/ } && result.any? { |e| e =~ /<\/front><middle1>/ }
          result = result.reject { |e| e =~ /<\/front><middle1>/ }
        else
          result = result.map { |e| e =~ /<\/front><middle1>/ ? "</front><middle>" : e }
        end

        result * "\n"
      end

      def inline_break(node)
        %(#{node.text}<vspace/>)
      end

      def inline_quoted(node)
        case node.type
        when :emphasis
          %(<spanx style="emph">#{node.text}</spanx>)
        when :strong
          %(<spanx style="strong">#{node.text}</spanx>)
        when :monospaced
          %(<spanx style="verb">#{node.text}</spanx>)
        when :double
          "\"#{node.text}\""
        when :single
          "'#{node.text}'"
        when :superscript
          "^#{node.text}^"
        when :subscript
          "_#{node.text}_"
        else
          # [bcp14]#MUST NOT#
          if node.role == "bcp14"
            %(<spanx style="strong">#{node.text.upcase}</spanx>)
          else
            node.text
          end
        end
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
          anchor: node.id,
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
    end
  end
end
