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
        ret = set_pis(node, Nokogiri::XML(ret)).to_xml
        ret = cleanup ret
        Validate::validate(ret)
        ret
      end

      def set_pis(node, doc)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use. (Here they are set differently than
        # their defaults in xml2rfc v1.32)
        rfc_pis = common_rfc_pis(node)

        doc.create_internal_subset("rfc", nil, "rfc2629.dtd")
        rfc_pis.each_pair do |k, v|
          pi = Nokogiri::XML::ProcessingInstruction.new(doc,
                                                        "rfc",
                                                        "#{k}=\"#{v}\"")
          doc.root.add_previous_sibling(pi)
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
          links = (node.attr("link") || "").split(/,/)
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
        'MUST', 'MUST NOT', 'REQUIRED', 'SHALL', 'SHALL NOT',
        'SHOULD', 'SHOULD NOT', 'RECOMMENDED', 'MAY', 'OPTIONAL'
      ]
      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis then xml.em node.text
          when :strong
            if $bcp_bold && BCP_KEYWORDS.exist?(node.text)
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

        if (node.parent.context == :preamble) && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

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
=begin
          result << noko do |xml|
            xml.references **attr_code(references_attributes) do |references_xml|
              references_xml.name node.title unless node.title.nil?
              node.blocks.each { |b| references_xml << reflist(b).join }
            end
          end

          anchor_attribute = node.id.nil? ? nil : " anchor=\"#{node.id}\""
          result << "<references#{anchor_attribute}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          # require that references be a :pass xml block
          # potentially with an initial block of display reference equivalences
          node.blocks.each do |b|
            if b.context == :pass
              result << reflist(b)
            elsif b.context == :section
              result << node.content
            elsif b.context == :ulist
              b.items.each do |i|
                i.text # we only process the item for its displayreferences
              end
            end
          end
          result << "</references>"
=end
          node.blocks.each do |block|
            if block.context == :section
              result << section(block)
            elsif block.context == :pass
              # we are assuming a single contiguous :pass block of XML
              result << noko do |xml|
                xml.references **attr_code(references_attributes) do |xml_references|
                  xml_references.name node.title unless node.title.nil?
                  xml_references << reflist(block).join
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
