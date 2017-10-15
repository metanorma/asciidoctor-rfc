module Asciidoctor
  module RFC::V2
    module Lists

      # Syntax:
      #   * A
      #   * B
      def ulist(node)
        noko { |xml| wrap_list :ulist_naked, node, xml }
      end

      OLIST_TYPES =
        Hash.new("numbers").merge(
          arabic:     "numbers",
          # decimal:    "1", # not supported
          loweralpha: "format %c",
          # lowergreek: "lower-greek", # not supported
          lowerroman: "format %i",
          upperalpha: "format %C",
          upperroman: "format %I",
        ).freeze

      # Syntax:
      #   [start=n] (optional)
      #   . A
      #   . B
      def olist(node)
        noko { |xml| wrap_list :olist_naked, node, xml }
      end

      # Syntax:
      #   [hangIndent=n] (optional)
      #   A:: B
      #   C:: D
      def dlist(node)
        noko { |xml| wrap_list :dlist_naked, node, xml }
      end

      private

      def wrap_list(method_name, node, xml)
        if node.parent.context !~ /paragraph|list_item/
          xml.t do |xml_t|
            send method_name, node, xml_t
          end
        else
          send method_name, node, xml
        end
      end

      def ulist_naked(node, xml)
        list_attributes = {
          style: "symbols",
        }.reject { |_, value| value.nil? }

        xml.list **list_attributes do |xml_list|
          node.items.each do |item|
            t_attributes = {
              anchor: nil,
            }.reject { |_, value| value.nil? }

            xml_list.t **t_attributes do |xml_t|
              xml_t << item.text
              xml_t << item.content if item.blocks?
            end
          end
        end
      end

      def olist_naked(node, xml)
        # TODO did I understand spec of @counter correctly?
        list_attributes = {
          counter: node.attr("start"),
          style: OLIST_TYPES[node.style.to_sym],
        }.reject { |_, value| value.nil? }

        xml.list **list_attributes do |xml_list|
          node.items.each do |item|
            t_attributes = {
              anchor: item.id,
            }.reject { |_, value| value.nil? }

            xml_list.t **t_attributes do |xml_t|
              xml_t << item.text
              xml_t << item.content if item.blocks?
            end
          end
        end
      end

      def dlist_naked(node, xml)
        list_attributes = {
          hangIndent: node.attr("hang-indent"),
          style: "hanging",
        }.reject { |_, value| value.nil? }

        xml.list **list_attributes do |xml_list|
          node.items.each do |terms, dd|
            t_attributes = {
              hangText: terms.map(&:text).join(", "),
            }.reject { |_, value| value.nil? }

            xml_list.t **t_attributes do |xml_t|
              if dd.blocks?
                xml_t << dd.text if dd.text?
                xml_t << dd.content
              else
                xml_t << dd.text
              end
            end
          end
        end
      end
    end
  end
end
