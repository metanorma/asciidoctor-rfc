module Asciidoctor
  module RFC::V3
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
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
      end

      private

      def inline_anchor_xref(node)
        text = node.text
        if text =~ /^\S+ (of|comma|parens|bare)\b/
          # <<crossreference#fragment,section (of|comma|parens|bare): text>> = relref
          matched = /(?<section>\S+)\s+(?<format>[a-z]+)(: )?(?<text>.*)$/.match node.text

          relref_contents = matched[:text]

          relref_attributes = {
            relative: node.attributes["path"].nil? ? nil : node.attributes["fragment"],
            section: matched[:section],
            displayFormat: matched[:format],
            target: node.target.gsub(/\..*$/, "").gsub(/^#/, ""),
          }

          noko do |xml|
            xml.relref relref_contents, **attr_code(relref_attributes)
          end.join
        else
          xref_contents = node.text

          matched = /^format=(?<format>counter|title|none|default):\s*(?<text>.*)$/.match xref_contents

          xref_contents = matched[:text] if matched

          xref_attributes = {
            format: matched&.[](:format),
            target: node.target.gsub(/^#/, ""),
          }

          noko do |xml|
            xml.xref xref_contents, **attr_code(xref_attributes)
          end.join
        end
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
        %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
      end

      def inline_anchor_ref(node)
        # If this is within referencegroup, output as bibanchor anyway
        if $processing_reflist
          %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
        else
          warn %(asciidoctor: WARNING: anchor "#{node.id}" is not in a place where XML RFC will recognise it as an anchor attribute)
        end
      end
    end
  end
end
