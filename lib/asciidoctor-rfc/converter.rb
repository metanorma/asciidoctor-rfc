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
        preptime = Time.now.getutc
        version = "3"
        # submissionType
        #
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}#{version}>)
        result << (document_info_element node)
        result << node.content if node.blocks?
        unless (footer_docinfo = node.docinfo :footer).empty?
          result << footer_docinfo
        end
        result << '</rfc>'

        result * "\n"
      end

    end
  end
