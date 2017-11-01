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
        $smart_quotes = (node.attr("smart-quotes") != "false")

        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'

        is_rfc = node.attr("doctype") == "rfc"

        consensus_value = {
          "false" => "no",
          "true" => "yes",
        }[node.attr("consensus")] || node.attr("consensus")

        category = node.attr("status")
        category = "info" if category == "informational"
        category = "std" if category == "standard"
        category = "exp" if category == "experimental"

        rfc_attributes = {
          ipr:            node.attr("ipr"),
          obsoletes:      node.attr("obsoletes"),
          updates:        node.attr("updates"),
          category:       category,
          consensus:      consensus_value,
          submissionType: node.attr("submission-type") || "IETF",
          iprExtract:     node.attr("ipr-extract"),
          docName:        (node.attr("name") unless is_rfc),
          number:         (node.attr("name") if is_rfc),
          seriesNo:       node.attr("series-no"),
          "xml:lang":     node.attr("xml-lang"),
        }

        rfc_open = noko { |xml| xml.rfc **attr_code(rfc_attributes) }.join.gsub(/\/>$/, ">")
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
        ret = set_pis(node, Nokogiri::XML(ret)).to_xml
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
            xml << ($smart_quotes ? "“#{node.text}”" : "\"#{node.text}\"")
          when :single
            xml << ($smart_quotes ? "‘#{node.text}’" : "'#{node.text}'")
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
        }

        result << noko do |xml|
          xml.t **attr_code(t_attributes) do |xml_t|
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
        }

        result << noko do |xml|
          xml.t **attr_code(t_attributes) do |xml_t|
            xml_t << node.content.gsub("\n", "<vspace/>\n")
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
          }

          result << noko do |xml|
            xml.references **attr_code(references_attributes) do |xml_references|
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
          }

          result << noko do |xml|
            xml.section **attr_code(section_attributes) do |xml_section|
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
        xmldoc = Nokogiri::XML(doc) do |config|
          config.noent
        end
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

      def set_pis(node, doc)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use. (Here they are set differently than
        # their defaults in xml2rfc v1.32)
        rfc_pis = {
          # give errors regarding ID-nits and DTD validation
          strict: "yes",

          # TOC control
          # generate a ToC
          toc: node.attr("toc-include") == "false" ? "no" : "yes",

          # the number of levels of subsections in ToC. default: 3
          tocdepth: node.attr("toc-depth") || "4",

          # References control

          # use symbolic references tags, i.e, [RFC2119] instead of [1]
          symrefs: "yes",

          # sort the reference entries alphabetically
          sortrefs: "yes",

          # Vertical whitespace control
          # (using these PIs as follows is recommended by the RFC Editor)

          # do not start each main section on a new page
          compact: "yes",

          # keep one blank line between list items
          subcompact: "no",
        }

        doc.create_internal_subset("rfc", nil, "rfc2629.dtd")
        rfc_pis.each_pair do |k, v|
          pi = Nokogiri::XML::ProcessingInstruction.new(doc,
                                                        "rfc",
                                                        "#{k}=\"#{v}\"")
          doc.root.add_previous_sibling(pi)
        end

        doc
      end

      # replace any <t>text</t> instances with <vspace/>text
      def para_to_vspace(doc)
        xmldoc = Nokogiri::XML("<fragment>#{doc}</fragment>")
        paras = xmldoc.xpath("/fragment/t")
        paras.each do |para|
          vspace = Nokogiri::XML::Element.new("vspace", xmldoc.document)
          para.before(vspace)
          para.replace(para.children)
        end
        xmldoc.root.children.to_xml(encoding: "US-ASCII")
      end
    end
  end
end
