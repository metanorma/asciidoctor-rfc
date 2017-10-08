module Asciidoctor
  module RFC::V3
    module Front
      # Syntax:
      #   = Title
      #   Author
      #   :METADATA
      def front(node)
        result = []
        result << "<front>"
        abbrev = get_header_attribute node, "abbrev"
        result << "<title#{abbrev}>#{node.doctitle}</title>"
        result << (series_info node)
        result << (author node)
        result << (date node)
        result << (area node)
        result << (workgroup node)
        result << (keyword node)
      end

      # Syntax:
      #   = Title
      #   Author
      #   :name rfc-* || Internet-Draft-Name
      #   :status (of this document)
      #   :intendedstatus (of internet draft once published as RFC)
      #   :rfcstatus (of RFC: full-standard|bcp|fyi number or info|exp|historic)
      #   :stream
      def series_info(node)
        result = []
        status = get_header_attribute node, "status"
        stream = get_header_attribute node, "stream", "IETF"
        name = node.attr "docname"
        rfc = true
        unless name.nil? && (not name.empty?)
          if name =~ /^rfc-?/i
            name = name.gsub(/^rfc-?/i, "")
            nameattr = set_header_attribute "name", "RFC"
          else
            nameattr = set_header_attribute "name", "Internet-Draft"
            rfc = false
          end
          name = name.gsub(/\.[^\/]+$/, "")
          value = set_header_attribute "value", name
          status = get_header_attribute node, "status"
          result << "<seriesInfo#{nameattr}#{status}#{stream}#{value}/>"

          intendedstatus = node.attr("intendedstatus")
          unless intendedstatus.nil? && (not rfc)
            status = set_header_attribute "status", intendedstatus
            nameattr = set_header_attribute "name", ""
            result << "<seriesInfo#{nameattr}#{status}#{value}/>"
          end

          rfcstatus = node.attr("rfcstatus")
          unless rfcstatus.nil? && rfc
            m = /^(\S+) (\d+)$/.match(rfcstatus)
            if m.nil?
              nameattr = set_header_attribute "name", ""
              status = set_header_attribute "status", rfcstatus
              value = set_header_attribute "value", ""
              result << "<seriesInfo#{nameattr}#{status}#{value}/>"
            else
              rfcstatus1 = m[1]
              rfcstatus2 = m[2]
              nameattr = set_header_attribute "name", ""
              status = set_header_attribute "status", rfcstatus1
              value = set_header_attribute "value", rfcstatus2
              result << "<seriesInfo#{nameattr}#{status}#{value}/>"
            end
          end
        end
        result
      end

      # Syntax:
      #   = Title
      #   Author;Author_2;Author_3
      #   :fullname
      #   :lastname
      #   :organization
      #   :email
      #   :fullname_2
      #   :lastname_2
      #   :organization_2
      #   :email_2
      #   :fullname_3
      #   :lastname_3
      #   :organization_3
      #   :email_3
      # @note recurse: author, author_2, author_3...
      def author(node)
        result = []
        result << author1(node, "")
        i = 2
        loop do
          suffix = "_#{i}"
          author = node.attr("author#{suffix}")
          fullname = node.attr("fullname#{suffix}")
          if author.nil? and fullname.nil?
            break
          end
          result << author1(node, suffix)
          i += 1
        end
        result.flatten
      end

      # Syntax:
      #   = Title
      #   Author (contains author firstname lastname middlename authorinitials email: Firstname Middlename Lastname <Email>)
      #   :fullname
      #   :lastname
      #   :forename_initials (excludes surname, unlike Asciidoc "initials" attribute)
      #   :organization
      #   :email
      #   :role
      #   :fax
      #   :uri
      #   :phone
      #   :postalLine (mutually exclusive with street city etc) (lines broken up by "\ ")
      #   :street
      #   :city
      #   :region
      #   :country
      #   :code
      def author1(node, suffix)
        result = []
        result << authorname(node, suffix)
        result << organization(node, suffix)
        result << address(node, suffix)
        result << "</author>"
        result
      end

      def organization(node, suffix)
        result = []
        organization = node.attr("organization#{suffix}")
        abbrev = nil
        result << "<organization#{abbrev}>#{organization}</organization>" unless organization.nil?
        result
      end

      def address(node, suffix)
        result = []
        postalline = node.attr("postal-line#{suffix}")
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
            (not street.nil?) || (not postalline.nil?)
          result << "<address>"
          if not street.nil? or not postalline.nil?
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

      # Syntax:
      #   = Title
      #   Author
      #   :revdate or :date
      def date(node)
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        unless revdate.nil?
          begin
            revdate.gsub!(/T.*$/, "")
            d = Date.iso8601 revdate
            day = set_header_attribute "day", d.day
            month = set_header_attribute "month", Date::MONTHNAMES[d.month]
            year = set_header_attribute "year", d.year
            result << "<date#{day}#{month}#{year}/>"
          rescue
            # nop
          end
        end
        result
      end
    end
  end
end
