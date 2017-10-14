module Asciidoctor
  module RFC::V2
    module Blocks
      # Syntax:
      # [discrete]
      # == Section
      def floating_title(node)
        noko do |xml|
          xml.t do |xml_t|
            xml_t.spanx node.title, style: "strong"
          end
        end
      end

      # Syntax:
      #   [[id]]
      #   .Name
      #   [align=left|center|right,alt=alt_text,type] (optional)
      #   ....
      #     literal
      #   ....
      def literal(node)
        artwork_attributes = {
          anchor: node.id,
          align: node.attr("align"),
          type: node.attr("type"),
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

          note_attributes = {
            title: node.title,
          }.reject { |_, value| value.nil? }

          note_contents = [paragraph1(node)].flatten.join("\n")

          result << noko do |xml|
            xml.note **note_attributes do |xml_note|
              xml_note << note_contents
            end
          end
        else
          cref_attributes = {
            anchor: node.id,
            source: node.attr("source"),
          }.reject { |_, value| value.nil? }

          cref_contents = node.blocks? ? flatten(node) : node.content
          cref_contents = [cref_contents].flatten.join("\n")
          warn <<~WARNING_MESSAGE if node.blocks?
            asciidoctor: WARNING: comment can not contain blocks of text in XML RFC:\n #{node.content}
          WARNING_MESSAGE

          result << noko do |xml|
            if node.parent.context !~ /table|example|paragraph/
              xml.t do |xml_t|
                xml_t.cref **cref_attributes do |xml_cref|
                  xml_cref << cref_contents
                end
              end
            else
              xml_t.cref **cref_attributes do |xml_cref|
                xml_cref << cref_contents
              end
            end
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
        figure_attributes = {
          anchor: node.id,
          align: node.attr("align"),
          alt: node.alt,
          title: node.title,
          'suppress-title': node.attr("suppress-title"),
          # TODO: is 'suppress-title' the correct attribute name?
        }.reject { |_, value| value.nil? }
        # TODO iref
        seen_artwork = false
        noko do |xml|
          xml.figure **figure_attributes do |xml_figure|
            node.blocks.each do |b|
              case b.context
              when :listing, :image, :literal
                xml_figure << send(b.context, b).join
                seen_artwork = true
              else
                # we want to see the para text, not its <t> container
                if seen_artwork
                  xml_figure.postamble b.content
                else
                  xml_figure.preamble b.content
                end
              end
            end
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
          align: node.attr("align"),
          alt: node.alt,
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
              xml_figure.artwork sourcecode_content, **sourcecode_attributes
            end
          else
            xml.artwork sourcecode_content, **sourcecode_attributes
          end
        end
      end
    end
  end
end
