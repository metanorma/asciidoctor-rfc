require "nokogiri"

module Asciidoctor
  module RFC::V2
    module Validate
      class << self
        def validate(doc)
          schema = Nokogiri::XML::RelaxNG(File.read(File.join(File.dirname(__FILE__), "validate2.rng")))
          schema.validate(doc).each do |error|
            $stderr.puts "V2 RELAXNG Validation: #{error.message}"
          end
        end
      end
    end
  end
end
