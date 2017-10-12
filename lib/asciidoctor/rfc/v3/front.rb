module Asciidoctor
  module RFC::V3
    module Front
      # Syntax:
      #   = Title
      #   Author
      #   :METADATA
      def front(node, xml)
        xml.front do |xml_front|
          title node, xml_front
          series_info node, xml_front
          author node, xml_front
          date node, xml_front
          area node, xml_front
          workgroup node, xml_front
          keyword node, xml_front
        end
      end

      def title(node, xml)
        title_attributes = {
          abbrev: node.attr("abbrev")
        }.reject { |_, val| val.nil? }
        xml.title node.doctitle, **title_attributes
      end

      def series_info(node, xml)
        docname = node.attr("name")
        unless docname.nil? or docname&.empty?
          is_rfc = docname =~ /^rfc-?/i || node.attr("doctype") == "rfc"

          name = is_rfc ? docname.gsub(/^rfc-?/i, "") : docname
          nameattr = is_rfc ? "RFC" : "Internet-Draft"
          value = name.gsub(/\.[^\/]+$/, "")

          seriesInfo_attributes = {
            name: nameattr,
            status: node.attr("status"),
            stream: node.attr("submission-type") || "IETF",
            value: value,
          }.reject { |_, val| val.nil? }
          xml.seriesInfo **seriesInfo_attributes

          intendedstatus = node.attr("intended-series")
          if !is_rfc && !intendedstatus.nil?
            unless intendedstatus =~ /^(standard|full-standard|bcp|fyi|informational|experimental|historic)$/
              warn %(asciidoctor: WARNING: disallowed value for intended-series: #{intendedstatus})
            end
            seriesInfo_attributes = {
              name: "",
              status: intendedstatus,
              value: value,
            }.reject { |_, val| val.nil? }
            xml.seriesInfo **seriesInfo_attributes
          end

          rfcstatus = intendedstatus
          if is_rfc && !rfcstatus.nil?
            m = /^(\S+) (\d+)$/.match rfcstatus
            if m.nil?
              rfcstatus = "exp" if rfcstatus == "experimental"
              rfcstatus = "info" if rfcstatus == "informational"
              unless rfcstatus =~ /^(info|exp|historic)$/
                warn %(asciidoctor: WARNING: disallowed value for intended-series with no series number: #{rfcstatus})
              end
            else
              unless m[1] =~ /^(standard|full-standard|bcp)$/
                warn %(asciidoctor: WARNING: disallowed value for intended-series with series number: #{m[1]})
              end
            end
            seriesInfo_attributes = {
              name: "",
              status: m.nil? ? rfcstatus : m[1],
              value: m.nil? ? value : m[2],
            }.reject { |_, val| val.nil? }
            xml.seriesInfo **seriesInfo_attributes
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
def date(node, xml)
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


# These three overrides must be removed once they replace their homonyms
# in common/base (they serve to avoid conflict with v2 until that moment)

def area(node, xml)
  node.attr("area")&.split(/, ?/)&.each do |ar|
    xml.area ar
  end
end

def workgroup(node, xml)
  node.attr("workgroup")&.split(/, ?/)&.each do |wg|
    xml.workgroup wg
  end
end

def keyword(node, xml)
  node.attr("keyword")&.split(/, ?/)&.each do |kw|
    xml.keyword kw
  end
end

          end
    end
  end
