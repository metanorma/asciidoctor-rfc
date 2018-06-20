require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/rfc/v2/converter"
require_relative "asciidoctor/rfc/v3/converter"
require_relative "asciidoctor/rfc/version"

if defined? Metanorma
  require_relative "metanorma/rfc"
  Metanorma::Registry.instance.register(Metanorma::Rfc::ProcessorV2)
  Metanorma::Registry.instance.register(Metanorma::Rfc::ProcessorV3)
end
