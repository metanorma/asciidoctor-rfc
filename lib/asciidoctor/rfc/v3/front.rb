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
        if (not name.nil?) && (not name.empty?)
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
        noko do |xml|
          author_attributes = {
            fullname: node.attr("author#{suffix}"),
            surname: node.attr("lastname#{suffix}"),
            initials: node.attr("forename_initials#{suffix}"),
            role: node.attr("role#{suffix}"),
          }.reject { |_, value| value.nil? }

          xml.author **author_attributes do |xml_sub|
            organization node, suffix, xml_sub
            address node, suffix, xml_sub
          end
        end
      end

      def organization(node, suffix, xml)
        organization = node.attr("organization#{suffix}")
        xml.organization organization unless organization.nil?
      end

      def address(node, suffix, xml)
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
        if [email, facsimile, uri, phone, street, postalline].any?
          xml.address do |xml_address|
            if [street, postalline].any?
              xml_address.postal do |xml_postal|
                if postalline.nil?
                  street&.split("\\ ")&.each { |st| xml_postal.street st }
                  xml_postal.city city unless city.nil?
                  xml_postal.region region unless region.nil?
                  xml_postal.code code unless code.nil?
                  xml_postal.country country unless country.nil?
                else
                  postalline&.split("\\ ")&.each { |pl| xml_postal.postalLine pl }
                end
              end
            end
            xml_address.phone phone unless phone.nil?
            xml_address.facsimile facsimile unless facsimile.nil?
            xml_address.email email unless email.nil?
            xml_address.uri uri unless uri.nil?
          end
        end
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
