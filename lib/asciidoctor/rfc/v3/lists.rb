module Asciidoctor
  module RFC::V3
    module Lists
      # Syntax:
      #   * [[[ref1]]] A
      #   * [[[ref2]]] B
      #   * [[[ref3]]] (Referencegroup: no content)
      #     * [[[ref4]]] C
      #     * [[[ref4]]] D
      # @note ulist repurposed as reference list
      #      def reflist(node)
      #        result = []
      #        if node.context == :ulist
      #          node.items.each do |item|
      #            # we expect the biblio anchor to be right at the start of the reference
      #            if item.blocks?
      #              # we expect any list to be embedded, and only one level of embedding
      #              # we expect no content in the referencegroup line other than the bibliographic anchor
      #              result << "<referencegroup>#{item.text}".gsub(/<referencegroup>\s*\[?<bibanchor="([^"]+)">\]?.*$/, "<referencegroup anchor=\"\\1\">")
      #              item.blocks.each { |b| result << reflist(b) }
      #              result << "</referencegroup>"
      #            else
      #              # quoteTitle = get_header_attribute item, "quoteTitle"
      #              # target = get_header_attribute item, "target"
      #              # annotation = get_header_attribute item, "annotation"
      #              # FIXME: [[[x]]] within embedded list is processed as [<bibref>]
      #              result << "<reference>#{item.text}</refcontent></reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference anchor=\"\\1\"><refcontent>")
      #            end
      #          end
      #        elsif node.context == :pass
      #          # we expect raw xml
      #          node.lines.each do |item|
      #            # undo XML substitution
      #            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
      #            result << ref
      #          end
      #        else
      #          warn %(asciidoctor: WARNING: references are not a ulist or raw XML: #{node.context})
      #        end
      #        result
      #      end

      # Syntax:
      #   [[id]]
      #   [empty=true,spacing=compact|normal] (optional)
      #   * A
      #   * B
      def ulist(node)
        result = []

        result << noko do |xml|
          ul_attributes = {
            anchor: node.id,
            empty: node.attr("empty"),
            spacing: node.attr("spacing"),
          }

          xml.ul **attr_code(ul_attributes) do |xml_ul|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }

              xml_ul.li **attr_code(li_attributes) do |xml_li|
                if item.blocks?
                  xml_li.t do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li << item.text
                end
              end
            end
          end
        end

        result
      end

      OLIST_TYPES = Hash.new("1").merge(
        arabic:     "1",
        # decimal:    "1", # not supported
        loweralpha: "a",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "i",
        upperalpha: "A",
        upperroman: "I",
      ).freeze

      # Syntax:
      #   [[id]]
      #   [start=n,group=n,spacing=normal|compact] (optional)
      #   . A
      #   . B
      def olist(node)
        result = []

        result << noko do |xml|
          type = OLIST_TYPES[node.style.to_sym]
          type = node.attr("format") unless node.attr("format").nil?
          ol_attributes = {
            anchor: node.id,
            start: node.attr("start"),
            group: node.attr("group"),
            type: type,
            spacing: ("compact" if node.style == "compact") || node.attr("spacing"),
          }

          xml.ol **attr_code(ol_attributes) do |xml_ol|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }
              xml_ol.li **attr_code(li_attributes) do |xml_li|
                if item.blocks?
                  xml_li.t do |t|
                    t << item.text
                  end
                  xml_li << item.content
                else
                  xml_li << item.text
                end
              end
            end
          end
        end
        result
      end

      # Syntax:
      #   [[id]]
      #   [horizontal,compact] (optional)
      #   A:: B
      #   C:: D
      def dlist(node)
        result = []

        result << noko do |xml|
          dl_attributes = {
            anchor: node.id,
            hanging: ("true" if node.style == "horizontal"),
            spacing: ("compact" if node.style == "compact"),
          }

          xml.dl **attr_code(dl_attributes) do |xml_dl|
            node.items.each do |terms, dd|
              terms.each_with_index do |dt, idx|
                xml_dl.dt { |xml_dt| xml_dt << dt.text }
                if idx < terms.size - 1
                  xml_dl.dd
                end
              end

              if dd.nil?
                xml_dl.dd
              else
                xml_dl.dd do |xml_dd|
                  if dd.blocks?
                    if dd.text?
                      xml_dd.t { |t| t << dd.text }
                    end
                    xml_dd << dd.content
                  else
                    xml_dd << dd.text
                  end
                end
              end
            end
          end
        end
        result
      end
    end
  end
end
