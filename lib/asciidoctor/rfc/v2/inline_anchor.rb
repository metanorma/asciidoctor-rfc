module Asciidoctor
  module RFC::V2
    module InlineAnchor
      def inline_anchor(node)
        case node.type
        when :xref
          matched = /^format=(?<format>counter|title|none|default):\s*(?<text>.*)$/.match node.text
          xref_contents = matched.nil? ? node.text : matched[:text]
          matched ||= {}

          xref_attributes = {
            target: node.target.gsub(/^#/, ""),
            format: matched[:format],
            align: node.attr("align"),
          }.reject { |_, value| value.nil? }

          noko do |xml|
            xml.xref xref_contents, **xref_attributes
          end.join
        when :link
          eref_contents = node.target == node.text ? nil : node.text

          eref_attributes = {
            target: node.target,
          }.reject { |_, value| value.nil? }

          noko do |xml|
            xml.eref eref_contents, **eref_attributes
          end.join
        when :bibref
          unless node.xreftext.nil?
            x = node.xreftext.gsub(/^\[(.+)\]$/, "\\1")
            if node.id != x
              $xreftext[node.id] = x
            end
          end
          # NOTE technically node.text should be node.reftext, but subs have already been applied to text
          %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
        when :ref
          # If this is within referencegroup, output as bibanchor anyway
          if $processing_reflist
            %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
          else
            warn %(asciidoctor: WARNING: anchor "#{node.id}" is not in a place where XML RFC will recognise it as an anchor attribute)
          end
        else
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
      end
    end
  end
end
