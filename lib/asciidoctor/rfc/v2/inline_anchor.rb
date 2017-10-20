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
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
      end

      private

      def inline_anchor_xref(node)
        if node.text =~ /^\S+ (of|comma|parens|bare)\b/
          # <<crossreference#fragment,section (of|comma|parens|bare): text>> = relref: 
          # render equivalent in v2
          matched = /(?<section>\S+)\s+(?<format>[a-z]+)(: )?(?<text>.*)$/.match node.text

          relref_contents = matched[:text]
          target = node.target.gsub(/\..*$/, "").gsub(/^#/, "")
          reftarget = target
          reftarget = "#{target}##{node.attributes["fragment"]}" unless node.attributes["path"].nil?

          xref_contents = case matched[:format]
                          when "of"
                            "Section #{matched[:section]} of [#{target}]"
                          when "comma"
                            "[#{target}], Section #{matched[:section]}"
                          when "parens"
                            "[#{target}] (Section #{matched[:section]})"
                          when "bare"
                            matched[:section]
                          else
                            "Section #{matched[:section]} of #{target}"
                          end

          xref_attributes = {
            target: reftarget
          }.reject { |_, value| value.nil? }

        else

          matched = /^format=(?<format>counter|title|none|default):\s*(?<text>.*)$/.match node.text
          xref_contents = matched.nil? ? node.text : matched[:text]
          matched ||= {}

          xref_attributes = {
            target: node.target.gsub(/^#/, ""),
            format: matched[:format],
            align: node.attr("align"),
          }.reject { |_, value| value.nil? }
        end

        noko do |xml|
          xml.xref xref_contents, **xref_attributes
        end.join
      end

      def inline_anchor_link(node)
        eref_contents = node.target == node.text ? nil : node.text

        eref_attributes = {
          target: node.target,
        }.reject { |_, value| value.nil? }

        noko do |xml|
          xml.eref eref_contents, **eref_attributes
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
