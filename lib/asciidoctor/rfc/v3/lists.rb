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

        if node.parent.context == :preamble && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        result << noko do |xml|
          ul_attributes = {
            anchor: node.id,
            empty: node.attr("empty"),
            spacing: node.attr("spacing"),
          }.reject { |_, value| value.nil? }

          xml.ul **ul_attributes do |xml_ul|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }.reject { |_, value| value.nil? }

              xml_ul.li **li_attributes do |xml_li|
                xml_li << item.text
                xml_li << item.content if item.blocks?
              end
            end
          end
        end

        result
      end

      OLIST_TYPES =
        Hash.new("1").merge(
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

        if node.parent.context == :preamble && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        result << noko do |xml|
          ol_attributes = {
            anchor: node.id,
            start: node.attr("start"),
            group: node.attr("group"),
            type: OLIST_TYPES[node.style.to_sym],
            spacing: ("compact" if node.style == "compact") || node.attr("spacing"),
          }.reject { |_, value| value.nil? }

          xml.ol **ol_attributes do |xml_ol|
            node.items.each do |item|
              li_attributes = {
                anchor: item.id,
              }.reject { |_, value| value.nil? }

              xml_ol.li **li_attributes do |xml_li|
                xml_li << item.text
                xml_li << item.content if item.blocks?
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

        if node.parent.context == :preamble && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        result << noko do |xml|
          dl_attributes = {
            anchor: node.id,
            hanging: ("true" if node.style == "horizontal"),
            spacing: ("compact" if node.style == "compact"),
          }.reject { |_, value| value.nil? }

          xml.dl **dl_attributes do |xml_dl|
            node.items.each do |terms, dd|
              terms.each { |dt| xml_dl.dt dt.text }

              xml_dl.dd do |xml_dd|
                if dd.blocks?
                  xml_dd << dd.text if dd.text?
                  xml_dd << dd.content
                else
                  xml_dd << dd.text
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
