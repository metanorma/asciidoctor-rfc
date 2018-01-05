require "nokogiri"
require "jing"

module Asciidoctor
  module RFC::V3
    module Validate
      class << self
        def validate(doc)
          # svg_location = File.join(File.dirname(__FILE__), "svg.rng")
          # schema = Nokogiri::XML::RelaxNG(File.read(File.join(File.dirname(__FILE__), "validate.rng")).
           #                              gsub(%r{<ref name="svg"/>}, "<externalRef href='#{svg_location}'/>"))

          filename = File.join(File.dirname(__FILE__), "validate.rng")
          schema = Jing.new(filename)
          File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
          begin
            errors = schema.validate(".tmp.xml")
          rescue Jing::Error => e
            abort "[asciidoctor-rfc] Validation error: #{e}"
          end

          if errors.none?
            $stderr.puts "[asciidoctor-rfc] Validation passed."
          else
            errors.each do |error|
              $stderr.puts "[asciidoctor-rfc] #{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end

        end
      end
    end
  end
end
