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
        $seen_abstract = false
        # If this is present, then BCP14 keywords in boldface are not assumed to be <bcp14> tags. By default they are.
        $bcp_bold = !(node.attr? "no-rfc-bold-bcp14")
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
          preptime:       preptime,
          version:        "3",
        }.reject { |_, value| value.nil? }

        rfc_open = noko { |xml| xml.rfc **rfc_attributes }.join.gsub(/\/>$/, ">")
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

        result * "\n"
      end

      # Syntax:
      #   = Title
      #   Author
      #   :link href,href rel
      def link(node)
        result = []
        result << noko do |xml|
          links = (node.attr("link") || "").split(/,/)
          links.each do |link|
            matched = /^(?<href>\S+)\s+(?<rel>\S+)$/.match link
            link_attributes = {
              href: matched.nil? ? link : matched[:href],
              rel: matched.nil? ? nil : matched[:rel],
            }.reject { |_, value| value.nil? }
            xml.link **link_attributes
          end
        end
        result
      end

      def inline_break(node)
        %(#{node.text}<br/>)
      end

      def inline_quoted(node)
        case node.type
        when :emphasis
          "<em>#{node.text}</em>"
        when :strong
          if $bcp_bold &&
              node.text =~ /^(MUST|MUST NOT|REQUIRED|SHALL|SHALL NOT|SHOULD|SHOULD NOT|RECOMMENDED|MAY|OPTIONAL)$/
            "<bcp14>#{node.text}</bcp14>"
          else
            "<strong>#{node.text}</strong>"
          end
        when :monospaced
          "<tt>#{node.text}</tt>"
        when :double
          "\"#{node.text}\""
        when :single
          "'#{node.text}'"
        when :superscript
          "<sup>#{node.text}</sup>"
        when :subscript
          "<sub>#{node.text}</sub>"
        else
          # [bcp14]#MUST NOT#
          if node.role == "bcp14"
            "<bcp14>#{node.text.upcase}</bcp14>"
          else
            node.text
          end
        end
      end

      # Syntax:
      #   [[id]]
      #   [keepWithNext=true,keepWithPrevious=true] (optional)
      #   Text
      def paragraph(node)
        result = []

        if (node.parent.context == :preamble) && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        t_attributes = {
          anchor: node.id,
          keepWithNext: node.attr("keep-with-next"),
          keepWithPrevious: node.attr("keep-with-previous"),
        }.reject { |_, value| value.nil? }

        result << noko do |xml|
          xml.t **t_attributes do |xml_t|
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
        if node.attr("style") == "bibliography"
          $xreftext = {}
          $processing_reflist = true

          # references_attributes = {
          #   anchor: node.id,
          # }.reject { |_, value| value.nil? }

          # result << noko do |xml|
          #   xml.references **references_attributes do |references_xml|
          #     references_xml.name node.title unless node.title.nil?
          #     node.blocks.each { |b| references_xml << reflist(b).join }
          #   end
          # end

          anchor_attribute = node.id.nil? ? nil : " anchor=\"#{node.id}\""
          result << "<references#{anchor_attribute}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          # require that references be given in a ulist
          node.blocks.each { |b| result << reflist(b) }
          result << "</references>"

          unless $xreftext.empty?
            result.unshift($xreftext.keys.map { |k| %(<displayreference target="#{k}" to="#{$xreftext[k]}"/>) })
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
          }.reject { |_, value| value.nil? }

          result << noko do |xml|
            xml.section **section_attributes do |section_xml|
              section_xml.name node.title unless node.title.nil?
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
