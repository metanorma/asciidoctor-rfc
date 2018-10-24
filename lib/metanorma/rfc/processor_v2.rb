require "metanorma/processor"

module Metanorma
  module Rfc
    class ProcessorV2 < Metanorma::Processor

      def initialize
        @short = :rfc2
        @input_format = :asciidoc
        @asciidoctor_backend = :rfc2
      end

      def output_formats
        {
          xmlrfc: "v2.xml"
        }
      end

      def version
        "Asciidoctor::Rfc2 #{Asciidoctor::RFC::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :xmlrfc
          File.open(outname, 'w') { |file| file << isodoc_node }
        end
      end

    end
  end
end
