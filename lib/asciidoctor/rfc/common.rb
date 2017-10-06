require "date"
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

      def organization node, suffix, version
        result = []
        organization = node.attr("organization#{suffix}")
        if version == 2
          organization_abbrev = node.attr("organization_abbrev#{suffix}")
          abbrev = set_header_attribute "abbrev", organization_abbrev
        else
          abbrev = nil
        end
        result << "<organization#{abbrev}>#{organization}</organization>" unless organization.nil?
        result
      end

      def address node, suffix, version
        result = []
        postalline = if version == 3 
                       node.attr("postalline#{suffix}")
                     else
                       nil
                     end
        street = node.attr("street#{suffix}")
        city = node.attr("city#{suffix}")
        region = node.attr("region#{suffix}")
        country = node.attr("country#{suffix}")
        code = node.attr("code#{suffix}")
        phone = node.attr("phone#{suffix}")
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        uri = node.attr("uri#{suffix}")
        if (not email.nil?) || (not facsimile.nil?) || (not uri.nil?) || (not phone.nil?) ||
          (not street.nil?)
          result << "<address>"
          if not street.nil?
            result << "<postal>"
            if postalline.nil?
              street&.split("\\ ")&.each { |p| result << "<street>#{p}</street>" }
              result << "<city>#{city}</city>" unless city.nil?
              result << "<region>#{region}</region>" unless region.nil?
              result << "<code>#{code}</code>" unless code.nil?
              result << "<country>#{country}</country>" unless country.nil?
            else
              postalline&.split("\\ ")&.each { |p| result << "<postalLine>#{p}</postalLine>" }
            end
            result << "</postal>"
          end
          result << "<phone>#{phone}</phone>" unless phone.nil?
          result << "<facsimile>#{facsimile}</facsimile>" unless facsimile.nil?
          result << "<email>#{email}</email>" unless email.nil?
          result << "<uri>#{uri}</uri>" unless uri.nil?
          result << "</address>"
        end
        result
      end


      def date(node, version)
        # = Title
        # Author
        # :revdate or :date
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        if version == 2
        # date is mandatory in v2: use today
        revdate = DateTime.now.iso8601 if revdate.nil?
        warn %(asciidoctor: WARNING: revdate attribute missing from header, provided current date) 
        puts revdate
        end
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

      def inline_anchor(node)
        case node.type
        when :xref
          # format attribute not supported
          unless (text = node.text) || (text = node.attributes['path'])
            refid = node.attributes['refid']
            text = %([#{refid}])
          end
          target = node.target.gsub(/^#/,"")
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

      def inline_indexterm node
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible 
          item = set_header_attribute "item", node.text
          "#{node.text}<iref#{item}/>"
        else
          item = set_header_attribute "item", terms[0]
          item = set_header_attribute "subitem", (terms.size > 1 ? terms[1] : nil)
          terms = node.attr "terms"
          "<iref#{item}#{subitem}/>"
          "<iref#{item}#{subitem}/>"
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(": ")}") if terms.size > 2
        end
      end

      def paragraph1 node
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

      def listing node, version
=begin
.name
[source,type,src=uri] (src is mutually exclusive with listing content) (v3)
[source,type,src=uri,align,alt] (src is mutually exclusive with listing content) (v2)
----
code
----
=end
        result = []
        result << "<figure>" if node.parent.context != :example
        if version == 2
          align = set_header_attribute "align", node.title
          alt = set_header_attribute "alt", node.alt
          tag = "artwork"
        else
          align = nil
          alt = nil
          tag = "sourcecode"
        end
        id = set_header_attribute "anchor", node.id
        name = set_header_attribute "name", node.title
        type = set_header_attribute "type", node.attr("language")
        src = set_header_attribute "src", node.attr("src")
        result << "<#{tag}#{id}#{align}#{name}#{type}#{src}#{alt}>"
        if src.nil?
          node.lines.each do |line|
            result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
          end
        end
        result << "</#{tag}>"
        result << "</figure>" if node.parent.context != :example
        result
      end


      def inline_image node, version
        result = []
        result << "<figure>" if node.parent.context != :example
        align = get_header_attribute node, "align"
        alt = get_header_attribute node, "alt"
        link =  (node.image_uri node.target)
        src = set_header_attribute node, "src", link
        type = if version == 3 
                 set_header_attribute node, "type", link =~ /\.svg$/ ? "svg" : "binary-art"
               else
                 nil
               end
        result << "<artwork#{align}#{alt}#{type}#{src}/>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      def image(node, version)
        # [[id]]
        # .Name
        # [link=xxx,align=left|center|right,alt=alt_text,type]
        # image::filename[]
        # ignoring width, height attributes
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        link = (node.image_uri node.target)
        src = set_header_attribute node, "src", link
        type = if version == 2
                 get_header_attribute node, "type"
               else 
                 set_header_attribute node, "type", 
                   link =~ /\.svg$/ ? "svg" : "binary-art"
               end
        name = if version == 2 
                 get_header_attribute node, "name"
               else
                 nil
               end
        result << "<artwork#{id}#{name}#{align}#{alt}#{type}#{src}/>"
        result << "</figure>" if node.parent.context != :example
        result
      end


      private

      def dash(camel_cased_word)
        camel_cased_word.gsub(/([a-z])([A-Z])/,'\1-\2').downcase
      end

    end
  end
end
