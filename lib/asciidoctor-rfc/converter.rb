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
        (node.attr? attr) ? %( #{attr}="#{node.attr attr}") : 
          default.nil? ? nil : %( #{attr}="#{default}")
      end

      def set_header_attribute attr, val
        %( #{attr}="#{val}")
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
      end

      def front node
=begin
= Title
Author
:stream
=end
        result = []
        abbrev = get_header_attribute node, "abbrev"
        result << "<front>"
        abbrev = get_header_attribute node, "abbrev"
        result << "<title#{abbrev}>#{node.doctitle}</title>"
        result << (series_info node)
        result << "</front>"
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
        if not name.nil? and not name.empty?
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
          if not intendedstatus.nil? and not rfc
            status = set_header_attribute "status", intendedstatus
            nameattr = set_header_attribute "name", ""
            result << "<seriesInfo#{nameattr}#{status}#{value}/>"
          end
          rfcstatus = node.attr("rfcstatus")
          if not rfcstatus.nil? and rfc
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
        # TODO
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
