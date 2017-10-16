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
            item: node.text,
          }.reject { |_, value| value.nil? }
          node.text + noko { |xml| xml.iref **iref_attributes }.join
        else
          terms = node.attr "terms"
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}) if terms.size > 2
          iref_attributes = {
            item: terms[0],
            subitem: (terms.size > 1 ? terms[1] : nil),
          }.reject { |_, value| value.nil? }
          noko { |xml| xml.iref **iref_attributes }.join
        end
      end

      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        result = []
        if node.context == :pass
          node.lines.each do |item|
            # undo XML substitution
            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
            result << ref
          end
        else
          warn %(asciidoctor: WARNING: references are not raw XML: #{node.context})
        end
        result
      end

      def dash(camel_cased_word)
        camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
      end

      # if node contains blocks, flatten them into a single line
      def flatten(node)
        result = []
        result << node.text if node.respond_to?(:text)
        if node.blocks?
          node.blocks.each { |b| result << flatten(b) }
        else
          result << node.content
        end
        result.reject(&:empty?)
      end

      # if node contains blocks, flatten them into a single line; and extract only raw text
      def flatten_rawtext(node)
        result = []
        if node.blocks?
          node.blocks.each { |b| result << flatten_rawtext(b) }
        elsif node.respond_to?(:lines)
          node.lines.each do |x|
            result << x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
          end
        elsif node.respond_to?(:text)
          result << node.text.gsub(/<[^>]*>/,"")
        else
          result << node.content.gsub(/<[^>]*>/,"")
        end
        result.reject(&:empty?)
      end

      def noko(&block)
        fragment = ::Nokogiri::XML::DocumentFragment.parse ""
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml.lines
      end
    end
  end
end
