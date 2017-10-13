module Asciidoctor
  module RFC::V2
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
        result << (author node)
        result << (date node)
        result << (area node)
        result << (workgroup node)
        result << (keyword node)
      end

      def organization(node, suffix, xml)
        organization = node.attr("organization#{suffix}")
        organization_abbrev = node.attr("organization_abbrev#{suffix}")
        organization_attributes = {
          abbrev: organization_abbrev,
        }.reject { |_, value| value.nil? }
        xml.organization organization, **organization_attributes unless organization.nil?
      end

      def address(node, suffix, xml)
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        phone = node.attr("phone#{suffix}")
        street = node.attr("street#{suffix}")
        uri = node.attr("uri#{suffix}")
        if [email, facsimile, phone, street, uri].any?
          xml.address do |xml_address|
            if [street].any?
              xml_address.postal do |xml_postal|
                city = node.attr("city#{suffix}")
                code = node.attr("code#{suffix}")
                country = node.attr("country#{suffix}")
                region = node.attr("region#{suffix}")
                street&.split("\\ ")&.each { |st| xml_postal.street st }
                xml_postal.city city unless city.nil?
                xml_postal.region region unless region.nil?
                xml_postal.code code unless code.nil?
                xml_postal.country country unless country.nil?
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
          if author.nil? && fullname.nil?
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
            fullname: node.attr("author#{suffix}") || node.attr("fullname#{suffix}"),
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

      # Syntax:
      #   = Title
      #   Author
      #   :revdate or :date
      def date(node)
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        # date is mandatory in v2: use today
        if revdate.nil?
          revdate = DateTime.now.iso8601
          warn %(asciidoctor: WARNING: revdate attribute missing from header, provided current date)
        end
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
