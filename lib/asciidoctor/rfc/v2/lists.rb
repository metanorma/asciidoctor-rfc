module Asciidoctor
  module RFC::V2
    module Lists
      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        result = []
        if node.context == :pass
          node.lines.each do |item|
            # undo XML substitution
            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
            result << ref
          end
        else
          warn %(asciidoctor: WARNING: references are not raw XML: #{node.context})
        end
        result
      end

      # Syntax:
      #   * A
      #   * B
      def ulist(node)
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        style = set_header_attribute "style", "symbols"
        result << "<list#{style}>"
        node.items.each do |item|
          # id = set_header_attribute "anchor", item.id
          id = nil
          if item.blocks?
            result << "<t#{id}>#{item.text}"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end

      (OLIST_TYPES = {
        arabic:     "numbers",
        # decimal:    "1", # not supported
        loweralpha: "format %c",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "format %i",
        upperalpha: "format %C",
        upperroman: "format %I",
      }).default = "numbers"

      # Syntax:
      #   [start=n] (optional)
      #   . A
      #   . B
      def olist(node)
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        counter = set_header_attribute "counter", node.attr("start")
        # TODO did I understand spec of @counter correctly?
        style = set_header_attribute "style", OLIST_TYPES[node.style.to_sym]
        result << "<list#{counter}#{style}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<t#{id}>#{item.text}"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end

      # Syntax:
      #   [hangIndent=n] (optional)
      #   A:: B
      #   C:: D
      def dlist(node)
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        hangIndent = get_header_attribute node, "hangIndent"
        style = set_header_attribute "style", "hanging"
        result << "<list#{hangIndent}#{style}>"
        node.items.each do |terms, dd|
          hangtext = []
          id = nil
          [*terms].each do |dt|
            hangtext << dt.text
          end
          hangText = set_header_attribute "hangText", hangtext.join(", ")
          if dd.blocks?
            result << "<t#{id}#{hangText}>"
            result << dd.text if dd.text?
            result << dd.content
            result << "</t>"
          else
            result << "<t#{id}#{hangText}>#{dd.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end
    end
  end
end
