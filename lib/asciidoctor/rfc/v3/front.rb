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

      def series_info(node, xml)
        docname = node.attr("name")
        return if docname.nil? || docname&.empty?
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
            warn %(asciidoctor: WARNING: disallowed value for intended-series with no series number: #{rfcstatus}) unless rfcstatus =~ /^(info|exp|historic)$/
          else
            warn %(asciidoctor: WARNING: disallowed value for intended-series with series number: #{m[1]}) unless m[1] =~ /^(standard|full-standard|bcp)$/
          end
          seriesInfo_attributes = {
            name: "",
            status: m.nil? ? rfcstatus : m[1],
            value: m.nil? ? value : m[2],
          }.reject { |_, val| val.nil? }
          xml.seriesInfo **seriesInfo_attributes
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
            address1 node, suffix, xml_address if [postalline, street].any?
            xml_address.phone phone unless phone.nil?
            xml_address.facsimile facsimile unless facsimile.nil?
            xml_address.email email unless email.nil?
            xml_address.uri uri unless uri.nil?
          end
        end
      end

      private

      def address1(node, suffix, xml_address)
        postalline = node.attr("postal-line#{suffix}")
        street = node.attr("street#{suffix}")
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
    end
  end
end
