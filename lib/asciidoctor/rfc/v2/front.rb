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
        }
        unless organization.nil?
          xml.organization **attr_code(organization_attributes) do |org|
            org << organization
          end
        end
      end

      def address(node, suffix, xml)
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        phone = node.attr("phone#{suffix}")
        street = node.attr("street#{suffix}")
        uri = node.attr("uri#{suffix}")
        return unless [email, facsimile, phone, street, uri].any?

        xml.address do |xml_address|

          xml_address.postal do |xml_postal|
            city = node.attr("city#{suffix}")
            code = node.attr("code#{suffix}")
            country = node.attr("country#{suffix}")
            region = node.attr("region#{suffix}")

            # https://tools.ietf.org/html/rfc7749#section-2.27
            # Note that at least one <street> element needs to be present; however,
            # formatters will handle empty values just fine.
            street = street ? street.split("\\ ") : [""]
            street.each { |st| xml_postal.street { |s| s << st } }

            xml_postal.city { |c| c << city } unless city.nil?
            xml_postal.region { |r| r << region } unless region.nil?
            xml_postal.code { |c| c << code } unless code.nil?
            xml_postal.country { |c| c << country } unless country.nil?
          end

          xml_address.phone { |p| p << phone } unless phone.nil?
          xml_address.facsimile { |f| f << facsimile } unless facsimile.nil?
          xml_address.email { |e| e << email } unless email.nil?
          xml_address.uri { |u| u << uri } unless uri.nil?
        end

      end
    end
  end
end
