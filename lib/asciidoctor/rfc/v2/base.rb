require "pp"
# coding: utf-8
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
        $smart_quotes = (node.attr("smart-quotes") != "false")
        $inline_definition_lists = (node.attr("inline-definition-lists") == "true")

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
        ret = cleanup(ret)
        ret1 = Nokogiri::XML(ret)
        # Validate::validate(ret1)
        ret1 = set_pis(node, ret1)
        ret1 = insert_biblio(node, ret1) unless node.attr("biblio-dir").nil? || node.attr("biblio-dir").empty?
        Validate::validate(ret1)
        ret1 = resolve_references(node, ret1)
        # Validate::validate(ret1)
        ret1.to_xml
      end

      def resolve_references(node, doc)
        extract_entities(node, doc).each do |entity|
          Nokogiri::XML::EntityDecl::new(entity[:entity], doc,
                                         Nokogiri::XML::EntityDecl::EXTERNAL_GENERAL_PARSED,
                                         nil, entity[:url], nil)
          entity[:node].replace(Nokogiri::XML::EntityReference.new(doc, entity[:entity]))
        end
        doc
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

        t_attributes = {
          anchor: node.id,
        }

        result << noko do |xml|
          xml.t **attr_code(t_attributes) do |xml_t|
            xml_t << node.content.gsub("\n\n", "<vspace blankLines=\"1\"/>").gsub("\n", "<vspace/>\n")
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
      #   == References
      #
      #   [bibliography]
      #   === Normative|Informative References
      #   ++++
      #   RFC XML references
      #   ++++
      def section(node)
        result = []
        if node.attr("style") == "bibliography" ||
            node.parent.context == :section && node.parent.attr("style") == "bibliography"
          $xreftext = {}
          $processing_reflist = true

          references_attributes = {
            title: node.title,
          }
          if node.blocks.empty?
            result << noko { |xml| xml.references **references_attributes }
          end
          node.blocks.each do |block|
            if block.context == :section
              result << node.content
            elsif block.context == :pass
              # NOTE: references are assumed to be found in a single passthrough
              #   block containing <reference> tags.

              result << noko do |xml|
                xml.references **references_attributes do |xml_references|
                  # NOTE: we're allowing the user to do more or less whathever
                  #   in the passthrough since the xpath below just fishes out ALL
                  #   <reference>s in an unrooted fragment, regardless of structure.
                  Nokogiri::XML::DocumentFragment.
                    parse(block.content).xpath(".//reference").
                    each { |reference| xml_references << reference.to_xml }
                end
              end
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
            figure_attributes = {
              anchor: node.id
            }
            xml.figure **attr_code(figure_attributes) do |xml_figure|
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

        # any crefs that are direct children of section should become children of the preceding
        # paragraph, if it exists; otherwise, they need to be wrapped in a paragraph
        crefs = xmldoc.xpath("//cref")
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
        # any instances of spanx must be stripped of any internal tags
        spanxs = xmldoc.xpath("//spanx[descendant::*]")
        while !spanxs.empty?
          spanx = spanxs[0]
          spanx_text = ""
          spanx.traverse do |node|
            spanx_text = spanx_text + node.text.gsub(/<[^>]+>/, "") if node.text?
          end
          spanx.children = spanx_text
          spanxs = xmldoc.xpath("//spanx[descendant::*]")
        end

        xmldoc.root = merge_vspace(xmldoc.root)

        # smart quotes: handle smart apostrophe
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

      def merge_vspace(node)
        nodes = []
        newnodes = []
        node.children.each do |element|
          nodes << element
        end

        counter = 0
        while counter < nodes.size
          if nodes[counter].name == "vspace"
            blankLines = 0
            while counter < nodes.size && nodes[counter].name == "vspace"
              blankLines += 1
              if nodes[counter][:blankLines].nil?
                blankLines += nodes[counter][:blankLines].to_i
              end
              if counter + 1 < nodes.size && nodes[counter + 1].text? && nodes[counter + 1].text =~ /\A[\n ]+\Z/m
                counter += 1
              end
              counter += 1
            end
            counter -= 1 if counter == nodes.size
            newnodes << noko do |xml|
              xml.vspace **attr_code(blankLines: (blankLines - 1))
            end.join
          else
            newnodes << merge_vspace(nodes[counter])
            counter += 1
          end
        end
        node.children.remove
        newnodes.each do |item|
          node.add_child(item)
        end
        node
      end

      # replace any <t>text</t> instances with <vspace blankLines="1"/>text
      def para_to_vspace(doc)
        xmldoc = Nokogiri::XML("<fragment>#{doc}</fragment>")
        paras = xmldoc.xpath("/fragment/t")
        paras.each do |para|
          # we do not insert vspace if the para contains a list: space will go there anyway
          unless para.element_children.size == 1 && para.element_children[0].name == "list"
            vspace = Nokogiri::XML::Element.new("vspace", xmldoc.document)
            vspace["blankLines"] = "1"
            para.before(vspace)
          end
          para.replace(para.children)
        end
        xmldoc.root.children.to_xml(encoding: "US-ASCII")
      end
    end
  end
end
