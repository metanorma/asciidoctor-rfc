module Asciidoctor
  module RFC::V2
    module Lists
      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        # TODO push through references as undigested XML
        result = []
        node.lines.each do |item|
          # we expect the biblio anchor to be right at the start of the reference
          target = get_header_attribute node, "target"
          # undo XML substitution
          ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
          # result << "<reference>#{ref}</reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference#{target} anchor=\"\\1\">")
          result << ref
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
        style = set_header_attribute "style", OLIST_TYPES[node.style]
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
            # we collapse multiple potential ids into the last seen
            id = set_header_attribute "anchor", dt.id unless dt.id.nil?
            hangtext << dt.text
          end
          unless dd.id.nil?
            id = set_header_attribute "anchor", dd.id
          end
          hangText = set_header_attribute "hangText", hangtext.join(", ")
          if dd.blocks?
            result << "<t#{id}#{hangText}>#{dd.text}"
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
