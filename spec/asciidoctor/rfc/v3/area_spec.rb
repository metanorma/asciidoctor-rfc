require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders areas" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :area: first_area, second_area
      
      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <area>first_area</area>
      <area>second_area</area>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
