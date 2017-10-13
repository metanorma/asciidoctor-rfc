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
      def reflist(node)
        result = []
        if node.context == :ulist
          node.items.each do |item|
            # we expect the biblio anchor to be right at the start of the reference
            if item.blocks?
              # we expect any list to be embedded, and only one level of embedding
              # we expect no content in the referencegroup line other than the bibliographic anchor
              result << "<referencegroup>#{item.text}".gsub(/<referencegroup>\s*\[?<bibanchor="([^"]+)">\]?.*$/, "<referencegroup anchor=\"\\1\">")
              item.blocks.each { |b| result << reflist(b) }
              result << "</referencegroup>"
            else
              # quoteTitle = get_header_attribute item, "quoteTitle"
              # target = get_header_attribute item, "target"
              # annotation = get_header_attribute item, "annotation"
              # FIXME: [[[x]]] within embedded list is processed as [<bibref>]
              result << "<reference>#{item.text}</refcontent></reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference anchor=\"\\1\"><refcontent>")
            end
          end
        elsif node.context == :pass
          # we expect raw xml
          node.lines.each do |item|
            # undo XML substitution
            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
            result << ref
          end
        else
          warn %(asciidoctor: WARNING: references are not a ulist or raw XML: #{node.context})
        end
        result
      end

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
        id = set_header_attribute "anchor", node.id
        empty = get_header_attribute node, "empty"
        spacing = get_header_attribute node, "spacing"
        result << "<ul#{id}#{empty}#{spacing}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>#{item.text}"
            result << item.content
            result << "</li>"
          else
            result << "<li#{id}>#{item.text}</li>"
          end
        end
        result << "</ul>"
        result
      end

      (OLIST_TYPES = {
        arabic:     "1",
        # decimal:    "1", # not supported
        loweralpha: "a",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "i",
        upperalpha: "A",
        upperroman: "I",
      }.freeze).default = "1"

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
        id = set_header_attribute "anchor", node.id
        spacing = set_header_attribute "spacing", "compact" if node.style == "compact"
        spacing = get_header_attribute node, "spacing" if spacing.nil?
        start = get_header_attribute node, "start"
        group = get_header_attribute node, "group"
        type = set_header_attribute "type", OLIST_TYPES[node.style.to_sym]
        result << "<ol#{id}#{spacing}#{start}#{group}#{type}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>#{item.text}"
            result << item.content
            result << "</li>"
          else
            result << "<li#{id}>#{item.text}</li>"
          end
        end
        result << "</ol>"
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
        id = set_header_attribute "anchor", node.id
        hanging = set_header_attribute "hanging", "true" if node.style == "horizontal"
        spacing = set_header_attribute "spacing", "compact" if node.style == "compact"
        result << "<dl#{id}#{hanging}#{spacing}>"
        id = nil
        node.items.each do |terms, dd|
          [*terms].each do |dt|
            result << "<dt>#{dt.text}</dt>"
          end
          if dd.blocks?
            result << "<dd>"
            if dd.text?
              result << dd.text
            end
            result << dd.content
            result << "</dd>"
          else
            result << "<dd#{id}>#{dd.text}</dd>"
          end
        end
        result << "</dl>"
        result
      end
    end
  end
end
