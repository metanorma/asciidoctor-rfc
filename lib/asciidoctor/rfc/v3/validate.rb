require "nokogiri"

module Asciidoctor
  module RFC::V3
    module Validate
      class << self
        def validate(doc)
          svg_location = File.join(File.dirname(__FILE__), "svg.rng")
          schema = Nokogiri::XML::RelaxNG(File.read(File.join(File.dirname(__FILE__), "validate.rng")).
                                         gsub(%r{<ref name="svg"/>}, "<externalRef href='#{svg_location}'/>"))
          schema.validate(doc).each do |error|
            $stderr.puts "V3 RELAXNG Validation: #{error.message}"
          end
        end
      end
    end
  end
end
