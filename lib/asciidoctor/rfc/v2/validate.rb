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
            abort "what what what #{e}"
          end
          if errors.none?
            puts "Valid!"
          else
            errors.each do |error|
              puts "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end
        end
      end
    end
  end
end
