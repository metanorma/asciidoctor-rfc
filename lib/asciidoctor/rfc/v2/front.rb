module Asciidoctor
  module RFC::V2
    module Front
      # Syntax:
      #   = Title
      #   Author
      #   :METADATA
      def front(node, xml)
        xml.front do |xml_front|
          title node, xml_front
          author node, xml_front
          date node, xml_front
          area node, xml_front
          workgroup node, xml_front
          keyword node, xml_front
        end
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
            revdate.gsub!(/T.*$/, "")
            d = Date.iso8601 revdate
            date_attributes = {
              day: d.day,
              month: Date::MONTHNAMES[d.month],
              year: d.year,
            }
            xml.date **date_attributes
          rescue ArgumentError # invalid date
            # nop
          end
        end
      end
    end
  end
end
