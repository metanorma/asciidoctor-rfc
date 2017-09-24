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

      def get_header_attribute node, attr
        (node.attr? attr) ? %( #{attr}="#{node.attr attr}") : nil
      end

      def set_header_attribute attr, val
        %( #{attr}="#{val}")
      end

      def document_ns_attributes doc
        #' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def document node
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        ipr = get_header_attribute node, "ipr"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        t = Time.now.getutc
        preptime = set_header_attribute "preptime", 
          sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", t.year, t.month, t.day, t.hour, t.min, t.sec)
        version = set_header_attribute "version", "3"
        # TODO submissionType
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}#{version}>)
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
        result = []
        result << "<title>#{node.doctitle}</title>"
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
