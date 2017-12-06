module Asciidoctor
  module RFC::V2
    module InlineAnchor
      def inline_anchor(node)
        case node.type
        when :xref
          inline_anchor_xref node
        when :link
          inline_anchor_link node
        when :bibref
          inline_anchor_bibref node
        when :ref
          inline_anchor_ref node
        else
          warn %(asciidoctor: WARNING (#{current_location(node)}): unknown anchor type: #{node.type.inspect})
        end
      end

      private

      def inline_anchor_xref(node)
        if node.text =~ /^\S+ (of|comma|parens|bare)\b/
          # <<crossreference#fragment,section (of|comma|parens|bare): text>> = relref:
          # render equivalent in v2
          matched = /(?<section>\S+)\s+(?<format>[a-z]+)(: )?(?<text>.*)$/.match node.text

          target = node.target.gsub(/\..*$/, "").gsub(/^#/, "")
          reftarget = target
          reftarget = "#{target}##{node.attributes['fragment']}" unless node.attributes["path"].nil?

          xref_contents = ""
          case matched[:format]
          when "of"
            prefix = "Section #{matched[:section]} of "
          when "comma"
            suffix = ", Section #{matched[:section]}"
          when "parens"
            suffix = " (Section #{matched[:section]})"
          when "bare"
            xref_contents = matched[:section]
          end
          unless matched[:text].empty?
            xref_contents = if xref_contents.empty?
                              matched[:text].to_s
                            else
                              "#{xref_contents}: #{matched[:text]}"
                            end
          end

          xref_attributes = {
            target: reftarget,
          }.reject { |_, value| value.nil? }

        else

          matched = /^format=(?<format>counter|title|none|default)(?<text>:\s*.*)?$/.match node.text
          xref_contents = if matched.nil?
                            node.text
                          else
                            matched[:text].nil? ? "" : matched[:text].gsub(/^:\s*/, "")
                          end
          matched ||= {}

          xref_attributes = {
            target: node.target.gsub(/^#/, ""),
            format: matched[:format],
            align: node.attr("align"),
          }
        end

        noko do |xml|
          xml << prefix unless prefix.nil? || prefix.empty?
          xml.xref xref_contents, **attr_code(xref_attributes)
          xml << suffix unless suffix.nil? || suffix.empty?
        end.join
      end

      def inline_anchor_link(node)
        eref_contents = node.target == node.text ? nil : node.text

        eref_attributes = {
          target: node.target,
        }

        noko do |xml|
          xml.eref eref_contents, **attr_code(eref_attributes)
        end.join
      end

      def inline_anchor_bibref(node)
        unless node.xreftext.nil?
          x = node.xreftext.gsub(/^\[(.+)\]$/, "\\1")
          if node.id != x
            $xreftext[node.id] = x
          end
        end
        # NOTE technically node.text should be node.reftext, but subs have already been applied to text
        # %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
        nil
      end

      def inline_anchor_ref(node)
        warn %(asciidoctor: WARNING (#{current_location(node)}): anchor "#{node.id}" is not in a place where XML RFC will recognise it as an anchor attribute)
      end
    end
  end
end
