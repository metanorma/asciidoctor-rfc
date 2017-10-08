module Asciidoctor
  module RFC::V2
    module Blocks
      # Syntax:
      #   [[id]]
      #   .Name
      #   [align=left|center|right,alt=alt_text,type] (optional)
      #   ....
      #     literal
      #   ....
      def literal(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        type = get_header_attribute node, "type"
        name = set_header_attribute "name", node.title

        result << "<artwork#{id}#{align}#{name}#{type}#{alt}>"
        node.lines.each do |line|
          result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
        end
        result << "</artwork>"

        result << "</figure>" if node.parent.context != :example
        result
      end

      # Syntax:
      #   = Title
      #   Author
      #   :HEADER
      #
      #   ABSTRACT
      #
      #   NOTE: note
      #
      #   [NOTE]
      #   .Title (in preamble)
      #   ====
      #     Content
      #   ====
      #
      #     [NOTE] (in preamble)
      #     [NOTE,source=name] (in body)
      #   .Title
      #   ====
      #     Content
      #   ====
      #
      # @note admonitions within preamble are notes. Elsewhere, they are comments.
      def admonition(node)
        result = []
        if node.parent.context == :preamble
          if $seen_abstract
            result << "</abstract>"
            $seen_abstract = false
          end
          title = set_header_attribute "title", node.title
          result << "<note#{title}>"
          result << (paragraph1 node)
          result << "</note>"
        else
          id = set_header_attribute "anchor", node.id
          source = get_header_attribute node, "source"
          if node.parent.context !~ /table|example|paragraph/
            result << "<t>"
          end
          result << "<cref#{id}#{source}>"
          result << node.content
          result << "</cref>"
          if node.parent.context !~ /table|example|paragraph/
            result << "</t>"
          end
        end
        result
      end

      # Syntax:
      #   [[id]]
      #   .Title
      #   [align,alt,suppress-title]
      #   ====
      #   Example
      #   ====
      def example(node)
        result = []
        id = set_header_attribute "anchor", node.id
        alt = set_header_attribute "alt", node.alt
        title = set_header_attribute "title", node.title
        suppresstitle = get_header_attribute node, "suppress-title"
        align = get_header_attribute node, "align"
        result << "<figure#{id}#{align}#{alt}#{title}#{suppresstitle}>"
        seen_artwork = false
        # TODO iref
        result.blocks.each do |b|
          if (b == :listing) || (b == :image) || (b == :literal)
            result << node.content
            seen_artwork = true
          else
            result << seen_artwork ? "<preamble>" : "<postamble>"
            result << node.content
            result << seen_artwork ? "</preamble>" : "</postamble>"
          end
        end
        result << "</figure>"
        result
      end

      # Syntax:
      #   .name
      #   [source,type,src=uri] (src is mutually exclusive with listing content) (v3)
      #   [source,type,src=uri,align,alt] (src is mutually exclusive with listing content) (v2)
      #   ----
      #   code
      #   ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        align = set_header_attribute "align", node.title
        alt = set_header_attribute "alt", node.alt
        tag = "artwork"
        id = set_header_attribute "anchor", node.id
        name = set_header_attribute "name", node.title
        type = set_header_attribute "type", node.attr("language")
        src = set_header_attribute "src", node.attr("src")
        result << "<#{tag}#{id}#{align}#{name}#{type}#{src}#{alt}>"
        if src.nil?
          node.lines.each do |line|
            result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
          end
        end
        result << "</#{tag}>"
        result << "</figure>" if node.parent.context != :example
        result
      end
    end
  end
end
