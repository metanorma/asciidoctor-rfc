module Asciidoctor
  module RFC::V3
    module Blocks
      # Syntax:
      # [discrete]
      # == Section
      def floating_title(node)
        noko do |xml|
          xml.t { |xml_t| xml_t.strong node.title }
        end
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

        # NOTE: html escaping is performed by Nokogiri
        artwork_content = node.lines.join("\n")

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

      def verse(node)
        cite_value = node.attr("citetitle")
        cite_value = nil unless cite_value.to_s =~ URI::DEFAULT_PARSER.make_regexp

        blockquote_attributes = {
          anchor: node.id,
          quotedFrom: node.attr("attribution"),
          cite: cite_value,
        }.reject { |_, value| value.nil? }

        noko do |xml|
          xml.blockquote **blockquote_attributes do |xml_blockquote|
            lines = node.content.split(/\n/)
            lines.each_with_index do |line, index|
              xml_blockquote << line
              xml_blockquote << "<br/>\n" unless index == lines.size - 1
            end
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
        noko do |xml|
          xml.aside anchor: node.id do |xml_aside|
            xml_aside << node.content
          end
        end
      end

      # Syntax:
      #   .Title
      #   ====
      #   Example
      #   ====
      def example(node)
        node.blocks.each do |b|
          unless %i{listing image literal}.include? b.context
            warn "asciidoctor: WARNING: examples (figures) should only contain listings (sourcecode), images (artwork), or literal (artwork):\n#{b.lines}"
          end
        end

        figure_attributes = {
          anchor: node.id,
        }.reject { |_, value| value.nil? }

        noko do |xml|
          xml.figure **figure_attributes do |xml_figure|
            xml_figure.name node.title if node.title?
            # TODO iref
            xml_figure << node.content
          end
        end
      end

      # Syntax:
      #   .name
      #   [source,type,src=uri] (src is mutually exclusive with listing content) (v3)
      #   [source,type,src=uri,align,alt] (src is mutually exclusive with listing content) (v2)
      #   ----
      #   code
      #   ----
      def listing(node)
        sourcecode_attributes = {
          anchor: node.id,
          align: nil,
          alt: nil,
          name: node.title,
          type: node.attr("language"),
          src: node.attr("src"),
        }.reject { |_, value| value.nil? }

        # NOTE: html escaping is performed by Nokogiri
        sourcecode_content =
          sourcecode_attributes[:src].nil? ? node.lines.join("\n") : ""

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.sourcecode sourcecode_content, **sourcecode_attributes
            end
          else
            xml.sourcecode sourcecode_content, **sourcecode_attributes
          end
        end
      end
    end
  end
end
