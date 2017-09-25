require "Date"
require "pp"

module Asciidoctor
  module Rfc
    # A {Converter} implementation that generates RFC XML output, a format used to 
    # format RFC proposals (https://tools.ietf.org/html/rfc7991)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md

    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      register_for 'rfc'

      def initialize backend, opts
        super
        #basebackend 'html'
        outfilesuffix '.xml'
      end

      def convert node, transform = nil, opts = {}
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def content node
        node.content
      end

      def skip node, name = nil
        warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        nil
      end

      def get_header_attribute node, attr, default = nil
        if (node.attr? attr) 
          %( #{attr}="#{node.attr attr}") 
        elsif default.nil? 
          nil 
        else 
          %( #{attr}="#{default}")
        end
      end

      def set_header_attribute attr, val
        if val.nil? 
          nil 
        else
          %( #{attr}="#{val}")
        end
      end

      def document_ns_attributes doc
        #' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def document node
=begin
=Title
Author
:ipr
:obsoletes
:updates
:submissionType
=end
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        ipr = get_header_attribute node, "ipr"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        submissionType = get_header_attribute node, "submisionType", "IETF"
        t = Time.now.getutc
        preptime = set_header_attribute "preptime", 
          sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", t.year, t.month, t.day, t.hour, t.min, t.sec)
        version = set_header_attribute "version", "3"
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}#{version}#{submissionType}>)
        result << (link node)
        result << (front node)
        result << "<middle>"
        result << node.content if node.blocks?
        result << "</middle>"
        result << (back node)
        result << "</rfc>"

        result * "\n"
      end

      def link node
        # TODO
        nil
      end

      def front node
=begin
= Title
Author
:METADATA
=end
        result = []
        abbrev = get_header_attribute node, "abbrev"
        result << "<front>"
        abbrev = get_header_attribute node, "abbrev"
        result << "<title#{abbrev}>#{node.doctitle}</title>"
        result << (series_info node)
        result << (author node)
        result << (date node)
        result << "</front>"
        # TODO area workgroup keyword abstract note boilerplate
      end

      def series_info node
=begin
= Title
Author
:name rfc-* || Internet-Draft-Name
:status (of this document)
:intendedstatus (of internet draft once published as RFC)
:rfcstatus (of RFC: full-standard|bcp|fyi number or info|exp|historic)
:stream
=end
        result = []
        status = get_header_attribute node, "status"
        stream = get_header_attribute node, "stream", "IETF"
        name = node.attr "docname"
        rfc = true
        unless name.nil? and not name.empty?
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
          unless intendedstatus.nil? and not rfc
            status = set_header_attribute "status", intendedstatus
            nameattr = set_header_attribute "name", ""
            result << "<seriesInfo#{nameattr}#{status}#{value}/>"
          end

          rfcstatus = node.attr("rfcstatus")
          unless rfcstatus.nil? and rfc
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

      def author node
=begin
= Title
Author;Author_2;Author_3
:fullname
:lastname
:organization
:email
:fullname_2
:lastname_2
:organization_2
:email_2
:fullname_3
:lastname_3
:organization_3
:email_3
=end
        # recurse: author, author_2, author_3...
        result = []
        result << author1(node, "")
        i = 2
        loop do
          suffix = "_#{i}"
          author = node.attr("author#{suffix}")
          if author.nil?
            break
          end
          result << author1(node, suffix)
        end
        result.flatten
      end

      def author1 node, suffix
=begin
= Title
Author (contains author firstname lastname middlename authorinitials email: Firstname Middlename Lastname <Email>)
:fullname
:lastname
:organization
:email
:role
:fax
:uri
:phone
:postalLine (mutually exclusive with street city etc) (lines broken up by "\ ")
:street
:city
:region
:country
:code
=end
        result = []
        authorname = set_header_attribute "fullname", node.attr("author#{suffix}")
        surname = set_header_attribute "surname", node.attr("lastname#{suffix}")
        initials = set_header_attribute "initials", node.attr("firstname#{suffix}")[0]
        role = set_header_attribute "role", node.attr("role#{suffix}")
        organization = node.attr("organization#{suffix}")
        postalline = node.attr("postalline#{suffix}")
        street = node.attr("street#{suffix}")
        city = node.attr("city#{suffix}")
        region = node.attr("region#{suffix}")
        country = node.attr("country#{suffix}")
        code = node.attr("code#{suffix}")
        phone = node.attr("phone#{suffix}")
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        uri = node.attr("uri#{suffix}")

        result << "<author#{authorname}#{initials}#{surname}#{role}>"
        result << "<organization>#{organization}</organization>" unless organization.nil?

        if not email.nil? or not facsimile.nil? or not uri.nil? or not phone.nil? or 
          not postalline.nil? or not street.nil?
          result << "<address>"
          if not postalline.nil? or not street.nil?
            result << "<postal>"
            if postalline.nil?
              result << "<street>#{street}</street>" unless street.nil?
              result << "<city>#{city}</city>" unless city.nil?
              result << "<region>#{region}</region>" unless region.nil?
              result << "<code>#{code}</code>" unless code.nil?
              result << "<country>#{country}</country>" unless country.nil?
            else
              postalline.split("\\ ").each { |p| result << "<postalLine>#{p}</postalLine>" }
            end
            result << "</postal>"
          end
          result << "<phone>#{phone}</phone>" unless phone.nil?
          result << "<facsimile>#{facsimile}</facsimile>" unless facsimile.nil?
          result << "<email>#{email}</email>"  unless email.nil?
          result << "<uri>#{uri}</uri>"  unless uri.nil?
          result << "</address>"
        end
        result << "</author>"
        result
      end

      def date node
=begin
= Title
Author
:revdate or :date
=end
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        unless revdate.nil?
          begin
            revdate.gsub!(/T.*$/, "")
                d = Date.iso8601 revdate
                pp d
                day = set_header_attribute "day", d.day
                month = set_header_attribute "month", d.month
                year = set_header_attribute "year", d.year
                result << "<date#{day}#{month}#{year}/>"
               rescue
                 # nop
               end
        end
        result
      end

      def back node
        # TODO
      end

      def preamble node
        warn "preamble material is ignored in conversion #{node.content}"
        nil
      end

      def paragraph node
        node.content
      end

      def section node
        node.content
      end

    end
  end
end
