module Asciidoctor
  module RFC::Common
    module Front
      def title(node, xml)
        title_attributes = {
          abbrev: node.attr("abbrev"),
        }
        xml.title **attr_code(title_attributes) do |t|
          t << node.doctitle
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
      def author(node, xml)
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
        role = node.attr("role#{suffix}")
        role = nil if role == "author"
        author_attributes = {
          fullname: node.attr("author#{suffix}") || node.attr("fullname#{suffix}"),
          surname: node.attr("lastname#{suffix}"),
          initials: node.attr("forename_initials#{suffix}"),
          role: role,
        }

        xml.author **attr_code(author_attributes) do |xml_sub|
          organization node, suffix, xml_sub
          address node, suffix, xml_sub
        end
      end

      def date1(revdate, xml)
        revdate.gsub!(/T.*$/, "")
        if revdate.length == 4
          date_attributes = {
            year: revdate,
          }
        elsif revdate =~ /^\d\d\d\d-?\d\d$/
          matched = /^(?<year>\d\d\d\d)-(?<month>\d\d)$/.match revdate
          date_attributes = {
            month: Date::MONTHNAMES[(matched[:month]).to_i],
            year: matched[:year],
          }
        else
          d = Date.iso8601 revdate
          date_attributes = {
            day: d.day,
            month: Date::MONTHNAMES[d.month],
            year: d.year,
          }
        end
        xml.date **attr_code(date_attributes)
      end

      # Syntax:
      #   = Title
      #   Author
      #   :revdate or :date
      def date(node, xml)
        revdate = node.attr("revdate") || node.attr("date")
        if revdate.nil?
          revdate = DateTime.now.iso8601
          warn %(asciidoctor: WARNING: revdate attribute missing from header, provided current date)
        end
        unless revdate.nil?
          begin
            date1(revdate, xml)
          rescue ArgumentError # invalid date
            warn %(asciidoctor: WARNING: invalid date in header, provided current date)
            date1(DateTime.now.iso8601, xml)
          end
        end
      end
    end
  end
end
