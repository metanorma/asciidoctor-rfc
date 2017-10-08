require "date"

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

      def authorname(node, suffix)
        result = []
        fullname = node.attr("author#{suffix}")
        fullname = node.attr("fullname#{suffix}") if fullname.nil?
        authorname = set_header_attribute "fullname", fullname
        surname = set_header_attribute "surname", node.attr("lastname#{suffix}")
        initials = set_header_attribute "initials", node.attr("forename_initials#{suffix}")
        role = set_header_attribute "role", node.attr("role#{suffix}")
        result << "<author#{authorname}#{initials}#{surname}#{role}>"
        result
      end

      # Syntax:
      #   = Title
      #   Author
      #   :area x, y
      def area(node)
        noko do |xml|
          node.attr("area")&.split(/, ?/)&.each do |ar|
            xml.area ar
          end
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node)
        noko do |xml|
          node.attr("workgroup")&.split(/, ?/)&.each do |wg|
            xml.workgroup wg
          end
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :keyword x, y
      def keyword(node)
        noko do |xml|
          node.attr("keyword")&.split(/, ?/)&.each do |kw|
            xml.keyword kw
          end
        end
      end

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          id = set_header_attribute "anchor", node.id
          result << "<t#{id}>#{result1}</t>"
        end
        result
      end

      def inline_indexterm(node)
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible
          item = set_header_attribute "item", node.text
          "#{node.text}<iref#{item}/>"
        else
          terms = node.attr 'terms'
          item = set_header_attribute "item", terms[0]
          subitem = set_header_attribute "subitem", (terms.size > 1 ? terms[1] : nil)
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}") if terms.size > 2
          "<iref#{item}#{subitem}/>"
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
        fragment = Nokogiri::XML::DocumentFragment.parse ""
        Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml.lines
      end
    end
  end
end
