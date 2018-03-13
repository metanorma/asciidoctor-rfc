require "htmlentities"

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
          align: node.attr("align"),
          type: node.attr("type"),
          name: node.title,
          alt: node.attr("alt"),
        }

        # NOTE: html escaping is performed by Nokogiri
        artwork_content = node.lines.join("\n")

        ret = noko do |xml|
          if node.parent.context != :example
            figure_attributes = {
              anchor: node.id,
            }
            xml.figure **attr_code(figure_attributes) do |xml_figure|
              xml_figure.artwork artwork_content, **attr_code(artwork_attributes)
            end
          else
            xml.artwork artwork_content, **attr_code(artwork_attributes)
          end
        end
        ret
      end

      # stem is treated as literal, but with center alignment
      def stem(node)
        artwork_attributes = {
          align: node.attr("align") || "center",
          type: node.attr("type"),
          name: node.title,
          alt: node.attr("alt"),
        }

        # NOTE: html escaping is performed by Nokogiri
        artwork_content = node.lines.join("\n")

        ret = noko do |xml|
          if node.parent.context != :example
            figure_attributes = {
              anchor: node.id,
            }
            xml.figure **attr_code(figure_attributes) do |xml_figure|
              xml_figure.artwork artwork_content, **attr_code(artwork_attributes)
            end
          else
            xml.artwork artwork_content, **attr_code(artwork_attributes)
          end
        end
        ret
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
          note_attributes = {
            # default title provided: title is mandatory
            title: (node.title.nil? ? "NOTE" : node.title),
          }

          note_contents = HTMLEntities.new.decode([paragraph1(node)].flatten.join("\n"))

          result << noko do |xml|
            xml.note **attr_code(note_attributes) do |xml_note|
              xml_note << note_contents
            end
          end
        else
          cref_attributes = {
            anchor: node.id,
            source: node.attr("source"),
          }

          # remove all formatting: cref content is pure text
          cref_contents = flatten_rawtext(node)
          cref_contents = [cref_contents].flatten.join("\n")
          warn <<~WARNING_MESSAGE if node.blocks?
            asciidoctor: WARNING (#{node.lineno}): comment can not contain blocks of text in XML RFC:\n #{node.content}
          WARNING_MESSAGE

          result << noko do |xml|
            if node.parent.context !~ /table|example|paragraph|section/
              xml.t do |xml_t|
                xml_t.cref **attr_code(cref_attributes) do |xml_cref|
                  xml_cref << cref_contents
                end
              end
            else
              xml.cref **attr_code(cref_attributes) do |xml_cref|
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
        }
        # TODO iref
        seen_artwork = false
        noko do |xml|
          xml.figure **attr_code(figure_attributes) do |xml_figure|
            node.blocks.each do |b|
              case b.context
              when :listing, :image, :literal, :stem
                xml_figure << send(b.context, b).join("\n")
                seen_artwork = true
              else
                # we want to see the para text, not its <t> container
                if seen_artwork
                  xml_figure.postamble do |postamble|
                    postamble << b.content
                  end
                else
                  xml_figure.preamble do |preamble|
                    preamble << b.content
                  end
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
          align: node.attr("align"),
          alt: node.alt,
          name: node.title,
          type: node.attr("language"),
          src: node.attr("src"),
        }

        # NOTE: html escaping is performed by Nokogiri
        sourcecode_content =
          sourcecode_attributes[:src].nil? ? node.lines.join("\n") : ""

        noko do |xml|
          if node.parent.context != :example
            figure_attributes = {
              anchor: node.id,
            }
            xml.figure **attr_code(figure_attributes) do |xml_figure|
              xml_figure.artwork sourcecode_content, **attr_code(sourcecode_attributes)
            end
          else
            xml.artwork sourcecode_content, **attr_code(sourcecode_attributes)
          end
        end
      end

      def quote(node)
        result = []
        if node.blocks?
          node.blocks.each do |b|
            result << send(b.context, b)
          end
        else
          result = paragraph(node)
        end
        if node.attr("citetitle") || node.attr("attribution")
          cite = node.attr("attribution") || ""
          cite += ", " if node.attr("citetitle") && node.attr("attribution")
          cite += node.attr("citetitle")
          cite = "-- " + cite
          result << "<t>#{cite}</t>"
        end
        result
      end

    end
  end
end
