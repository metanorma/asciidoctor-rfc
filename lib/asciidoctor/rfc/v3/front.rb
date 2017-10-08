module Asciidoctor
  module RFC::V3
    module Front
      # Syntax:
      #   = Title
      #   Author
      #   :METADATA
      def front(node)
        # FIXME: front should be opened and closed here
        result = []
        result << "<front>"
        result << (title node)
        result << (series_info node)
        result << (author node)
        result << (date node)
        result << (area node)
        result << (workgroup node)
        result << (keyword node)
      end

      def title(node)
        noko do |xml|
          title_attributes = {
            abbrev: node.attr("abbrev")
          }.reject { |_, val| val.nil? }
          xml.title node.doctitle, **title_attributes
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :name is_rfc-* || Internet-Draft-Name
      #   :status (of this document)
      #   :intendedstatus (of internet draft once published as RFC)
      #   :rfcstatus (of RFC: full-standard|bcp|fyi number or info|exp|historic)
      #   :stream
      def series_info(node)
        noko do |xml|
          docname = node.attr("docname")

          unless docname&.empty?
            is_rfc = docname =~ /^rfc-?/i

            name = is_rfc ? docname.gsub(/^rfc-?/i, "") : docname
            nameattr = is_rfc ? "RFC" : "Internet-Draft"
            value = name.gsub(/\.[^\/]+$/, "")

            seriesInfo_attributes = {
              name: nameattr,
              status: node.attr("status"),
              stream: node.attr("stream") || "IETF",
              value: value,
            }.reject { |_, val| val.nil? }
            xml.seriesInfo **seriesInfo_attributes

            intendedstatus = node.attr("intendedstatus")
            if is_rfc || !intendedstatus.nil?
              seriesInfo_attributes = {
                name: "",
                status: intendedstatus,
                value: value,
              }.reject { |_, val| val.nil? }
              xml.seriesInfo **seriesInfo_attributes
            end

            rfcstatus = node.attr("rfcstatus")
            if !is_rfc || !rfcstatus.nil?
              m = /^(\S+) (\d+)$/.match rfcstatus
              seriesInfo_attributes = {
                name: "",
                status: m.nil? ? rfcstatus : m[1],
                value: m.nil? ? "" : m[2],
              }.reject { |_, val| val.nil? }
              xml.seriesInfo **seriesInfo_attributes
            end
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
        noko do |xml|
          author1(node, "", xml)
          i = 2
          loop do
            suffix = "_#{i}"
            author = node.attr("author#{suffix}")
            fullname = node.attr("fullname#{suffix}")
            break unless [author, fullname].any?
            author1(node, suffix, xml)
            i += 1
          end
        end
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
      def author1(node, suffix, xml)
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

      def organization(node, suffix, xml)
        organization = node.attr("organization#{suffix}")
        xml.organization organization unless organization.nil?
      end

      def address(node, suffix, xml)
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        phone = node.attr("phone#{suffix}")
        postalline = node.attr("postal-line#{suffix}")
        street = node.attr("street#{suffix}")
        uri = node.attr("uri#{suffix}")
        if [email, facsimile, phone, postalline, street, uri].any?
          xml.address do |xml_address|
            if [postalline, street].any?
              xml_address.postal do |xml_postal|
                if postalline.nil?
                  city = node.attr("city#{suffix}")
                  code = node.attr("code#{suffix}")
                  country = node.attr("country#{suffix}")
                  region = node.attr("region#{suffix}")
                  xml_postal.city city unless city.nil?
                  xml_postal.code code unless code.nil?
                  xml_postal.country country unless country.nil?
                  xml_postal.region region unless region.nil?
                  street&.split("\\ ")&.each { |st| xml_postal.street st }
                else
                  postalline&.split("\\ ")&.each { |pl| xml_postal.postalLine pl }
                end
              end
            end
            xml_address.email email unless email.nil?
            xml_address.facsimile facsimile unless facsimile.nil?
            xml_address.phone phone unless phone.nil?
            xml_address.uri uri unless uri.nil?
          end
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :revdate or :date
      def date(node)
        noko do |xml|
          revdate = node.attr("revdate") || node.attr("date")
          unless revdate.nil?
            begin
              revdate.gsub!(/T.*$/, "")
              d = Date.iso8601 revdate
              date_attributes = {
                day: d.day,
                month: Date::MONTHNAMES[d.month],
                year: d.year,
              }
              xml.date **date_attributes
            rescue
              # nop
            end
          end
        end
      end
    end
  end
end
