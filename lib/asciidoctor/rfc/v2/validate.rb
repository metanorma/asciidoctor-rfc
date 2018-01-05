require "nokogiri"
require "jing"

module Asciidoctor
  module RFC::V2
    module Validate
      class << self
        def validate(doc)
          filename = File.join(File.dirname(__FILE__), "validate2.rng")
          schema = Jing.new(filename)

          File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }

          begin
            errors = schema.validate(".tmp.xml")
          rescue Jing::Error => e
            abort "[asciidoctor-rfc] Validation error: #{e}"
          end

          if errors.none?
            warn "[asciidoctor-rfc] Validation passed."
          else
            errors.each do |error|
              warn "[asciidoctor-rfc] #{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end

        end
      end
    end
  end
end
