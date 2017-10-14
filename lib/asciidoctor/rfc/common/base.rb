require "date"
require "nokogiri"

module Asciidoctor
  module RFC::Common
    module Base
      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def document_ns_attributes(_doc)
        # ' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        nil
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
      # @note (boilerplate is ignored)
      def preamble(node)
        result = []
        $seen_abstract = false
        result << node.content
        if $seen_abstract
          result << "</abstract>"
        end
        result << "</front><middle>"
        result
      end

      # TODO: dead code? remove.
      # def authorname(node, suffix)
      #   noko do |xml|
      #     author_attributes = {
      #       fullname: node.attr("author#{suffix}") || node.attr("fullname#{suffix}"),
      #       surname: node.attr("lastname#{suffix}"),
      #       initials: node.attr("forename_initials#{suffix}"),
      #       role: node.attr("role#{suffix}"),
      #     }.reject { |_, value| value.nil? }
      #     xml.author **author_attributes
      #   end
      # end

      # Syntax:
      #   = Title
      #   Author
      #   :area x, y
      def area(node, xml)
        node.attr("area")&.split(/, ?/)&.each do |ar|
          xml.area ar
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node, xml)
        node.attr("workgroup")&.split(/, ?/)&.each do |wg|
          xml.workgroup wg
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :keyword x, y
      def keyword(node, xml)
        node.attr("keyword")&.split(/, ?/)&.each do |kw|
          xml.keyword kw
        end
      end

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          t_attributes = {
            anchor: node.id,
          }.reject { |_, value| value.nil? }
          result << noko { |xml| xml.t result1, **t_attributes }
        end
        result
      end

      def inline_indexterm(node)
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible
          iref_attributes = {
            item: node.text
          }.reject { |_, value| value.nil? }
          node.text + noko { |xml| xml.iref **iref_attributes }.join
        else
          terms = node.attr "terms"
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}") if terms.size > 2
          iref_attributes = {
            item: terms[0],
            subitem: (terms.size > 1 ? terms[1] : nil),
          }.reject { |_, value| value.nil? }
          noko { |xml| xml.iref **iref_attributes }.join
        end
      end

      def dash(camel_cased_word)
        camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
      end

      # if node contains blocks, flatten them into a single line
      def flatten(node)
        result = []
        if node.blocks?
          if node.respond_to?(:text)
            result << node.text
          end
          node.blocks.each { |b| result << flatten(b) }
        else
          if node.respond_to?(:text)
            result << node.text
          end
          result << node.content
        end
        result.reject { |e| e.empty? }
      end

      def get_header_attribute(node, attr, default = nil)
        if node.attr? dash(attr)
          %( #{attr}="#{node.attr dash(attr)}")
        elsif default.nil?
          nil
        else
          %( #{attr}="#{default}")
        end
      end

      def set_header_attribute(attr, val)
        if val.nil?
          nil
        else
          %( #{attr}="#{val}")
        end
      end

      def noko(&block)
        fragment = ::Nokogiri::XML::DocumentFragment.parse ""
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml.lines
      end
    end
  end
end
