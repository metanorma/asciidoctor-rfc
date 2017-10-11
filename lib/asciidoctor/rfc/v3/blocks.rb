module Asciidoctor
  module RFC::V3
    module Blocks

      # Syntax:
      # [discrete]
      # == Section
      def floating_title(node)
        result = []
        result << %{<t><strong>#{node.title}</strong></t>}
        result
      end

      # Syntax:
      #   [[id]]
      #   .name
      #   [align=left|center|right,alt=alt_text] (optional)
      #   ....
      #     literal
      #   ....
      def literal(node)
        artwork_attributes = {
          anchor: node.id,
          align: node.attr("align"),
          type: "ascii-art",
          name: node.title,
          alt: node.attr("alt"),
        }.reject { |_, value| value.nil? }

        artwork_content = node.lines.map do |line|
          # TODO: this could be done with a more generic html escaper
          line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
        end.join("\n")

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.artwork artwork_content, **artwork_attributes
            end
          else
            xml.artwork artwork_content, **artwork_attributes
          end
        end
      end

      # Syntax:
      #   [[id]]
      #   [quote, attribution, citation info] # citation info limited to URL
      #   Text
      def quote(node)
        cite_value = node.attr("citetitle")
        cite_value = nil unless cite_value.to_s =~ URI::DEFAULT_PARSER.make_regexp

        blockquote_attributes = {
          anchor: node.id,
          quotedFrom: node.attr("attribution"),
          cite: cite_value,
        }.reject { |_, value| value.nil? }

        noko do |xml|
          xml.blockquote **blockquote_attributes do |xml_blockquote|
            xml_blockquote << node.content
          end
        end
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
            warn "asciidoctor: WARNING: comment can not contain blocks of text in XML RFC:\n #{node.content}"
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
        result << node.content
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
            warn "asciidoctor: WARNING: examples (figures) should only contain listings (sourcecode), images (artwork), or literal (artwork):\n#{b.lines}"
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
