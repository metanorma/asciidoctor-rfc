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
        if [email, facsimile, phone, street, uri].any?
          xml.address do |xml_address|
            if [street].any?
              xml_address.postal do |xml_postal|
                city = node.attr("city#{suffix}")
                code = node.attr("code#{suffix}")
                country = node.attr("country#{suffix}")
                region = node.attr("region#{suffix}")
                street&.split("\\ ")&.each { |st| xml_postal.street { |s| s << st } }
                xml_postal.city { |c| c << city } unless city.nil?
                xml_postal.region { |r| r << region } unless region.nil?
                xml_postal.code { |c| c << code } unless code.nil?
                xml_postal.country { |c| c << country } unless country.nil?
              end
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
end
