require "asciidoctor"

module Asciidoctor
  module RFC::Common
    class << self
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      def content(node)
        node.content
      end

      def skip node, name = nil
        warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        nil
      end

      # TODO: this ought to be private
      def dash(camel_cased_word)
        camel_cased_word.gsub(/([a-z])([A-Z])/,'\1-\2').downcase
      end

      def get_header_attribute node, attr, default = nil
        if (node.attr? dash(attr)) 
          %( #{attr}="#{node.attr dash(attr)}") 
        elsif default.nil? 
          nil 
        else 
          %( #{attr}="#{default}")
        end
      end

      def set_header_attribute attr, val
        if val.nil? 
          nil 
        else
          %( #{attr}="#{val}")
        end
      end

def authorname node, suffix
        result = []
        authorname = set_header_attribute "fullname", node.attr("author#{suffix}")
        surname = set_header_attribute "surname", node.attr("lastname#{suffix}")
        initials = set_header_attribute "initials", node.attr("forename_initials#{suffix}")
        role = set_header_attribute "role", node.attr("role#{suffix}")
        result << "<author#{authorname}#{initials}#{surname}#{role}>"
        result
end

      def date(node)
        # = Title
        # Author
        # :revdate or :date
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        unless revdate.nil?
          begin
            revdate.gsub!(/T.*$/, "")
            d = Date.iso8601 revdate
            day = set_header_attribute "day", d.day
            month = set_header_attribute "month", d.month
            year = set_header_attribute "year", d.year
            result << "<date#{day}#{month}#{year}/>"
          rescue
            # nop
          end
        end
        result
      end

      def area(node)
        # = Title
        # Author
        # :area x, y
        result = []
        area = node.attr("area")
        area&.split(/, ?/)&.each { |a| result << "<area>#{a}</area>" }
        result
      end

      def workgroup(node)
        # = Title
        # Author
        # :workgroup x, y
        result = []
        workgroup = node.attr("workgroup")
        workgroup&.split(/, ?/)&.each { |a| result << "<workgroup>#{a}</workgroup>" }
        result
      end

      def keyword(node)
        # = Title
        # Author
        # :keyword x, y
        result = []
        keyword = node.attr("keyword")
        keyword&.split(/, ?/)&.each { |a| result << "<keyword>#{a}</keyword>" }
        result
      end



    end
  end
end
