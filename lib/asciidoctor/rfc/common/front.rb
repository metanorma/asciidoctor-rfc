module Asciidoctor
  module RFC::Common
    module Front
      def title(node, xml)
        title_attributes = {
          abbrev: node.attr("abbrev"),
        }.reject { |_, val| val.nil? }
        xml.title node.doctitle, **title_attributes
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
          role: role
        }.reject { |_, value| value.nil? }

        xml.author **author_attributes do |xml_sub|
          organization node, suffix, xml_sub
          address node, suffix, xml_sub
        end
      end
    end
  end
end
