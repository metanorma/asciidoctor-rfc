module Asciidoctor
  module RFC::V3
    module Blocks
      # Syntax:
      #   [[id]]
      #   [align=left|center|right,alt=alt_text] (optional)
      #   ....
      #     literal
      #   ....
      def literal(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        type = set_header_attribute "type", "ascii-art"
        result << "<artwork#{id}#{align}#{alt}#{type}>"
        node.lines.each do |line|
          result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
        end
        result << "</artwork>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      # Syntax:
      #   [[id]]
      #   [quote, attribution, citation info] # citation info limited to URL
      #   Text
      def quote(node)
        result = []
        id = set_header_attribute "anchor", node.id
        quotedFrom = set_header_attribute "quotedFrom", node.attr("attribution")
        citationInfo = node.attr "citetitle"
        if !citationInfo.nil? && citationInfo =~ URI::DEFAULT_PARSER.make_regexp
          cite = set_header_attribute "cite", citationInfo
        end
        result << "<blockquote#{id}#{quotedFrom}#{cite}>"
        result << node.content
        result << "</blockquote>"
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
      #     [NOTE,removeInRFC=true] (in preamble)
      #     [NOTE,display=true|false,source=name] (in body)
      #   .Title
      #   ====
      #     Content
      #   ====
      # @note admonitions within preamble are notes. Elsewhere, they are comments.
      def admonition(node)
        result = []
        if node.parent.context == :preamble
          if $seen_abstract
            $seen_abstract = false
            result << "</abstract>"
          end
          removeInRFC = get_header_attribute node, "removeInRFC"
          result << "<note#{removeInRFC}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          result << (paragraph1 node)
          result << "</note>"
        else
          id = set_header_attribute "anchor", node.id
          display = get_header_attribute node, "display"
          source = get_header_attribute node, "source"
          result << "<cref#{id}#{display}#{source}>"
          if node.blocks?
            warn "asciidoctor: WARNING: comment can not contain blocks of text in XML RFC:\n #{node.lines}"
            result << flatten(node)
          else
            result << node.content
          end
          result << "</cref>"
        end
        result
      end

      # Syntax:
      #   [[id]]
      #   ****
      #   Sidebar
      #   ****
      def sidebar(node)
        result = []
        id = set_header_attribute "anchor", node.id
        result << "<aside#{id}>"
        result << cell.content
        result << "</aside>"
        result
      end

      # Syntax:
      #   .Title
      #   ====
      #   Example
      #   ====
      def example(node)
        result = []
        id = set_header_attribute "anchor", node.id
        result << "<figure#{id}>"
        result << %(<name>#{node.title}</name>) if node.title?
        # TODO iref
        result << node.content
        result << "</figure>"
        node.blocks.each do |b|
          unless b.context == :listing or b.context == :image or b.context == :literal
            warn "asciidoctor: WARNING: examples (figures) should only contain listings (sourcecode), images (artwork), or literal (artwork):\n#{b.text}"
          end
        end
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
        align = nil
        alt = nil
        tag = "sourcecode"
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
