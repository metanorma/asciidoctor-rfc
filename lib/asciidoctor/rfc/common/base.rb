require "date"
require "asciidoctor"

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

      def authorname(node, suffix)
        result = []
        authorname = set_header_attribute "fullname", node.attr("author#{suffix}")
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
        result = []
        area = node.attr("area")
        area&.split(/, ?/)&.each { |a| result << "<area>#{a}</area>" }
        result
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node)
        result = []
        workgroup = node.attr("workgroup")
        workgroup&.split(/, ?/)&.each { |a| result << "<workgroup>#{a}</workgroup>" }
        result
      end

      # Syntax:
      #   = Title
      #   Author
      #   :keyword x, y
      def keyword(node)
        result = []
        keyword = node.attr("keyword")
        keyword&.split(/, ?/)&.each { |a| result << "<keyword>#{a}</keyword>" }
        result
      end

      def inline_anchor(node)
        case node.type
        when :xref
          # format attribute not supported
          unless (text = node.text) || (text = node.attributes["path"])
            refid = node.attributes["refid"]
            text = %([#{refid}])
          end
          target = node.target.gsub(/^#/, "")
          %(<xref target="#{target}">#{text}</xref>)
        when :link
          %(<eref target="#{target}">#{node.text}</eref>)
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

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          id = set_header_attribute "anchor", node.id
          result << "<t#{id}>"
          result << result1
          result << "</t>"
        end
        result
      end

      def dash(camel_cased_word)
        camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
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
    end
  end
end
