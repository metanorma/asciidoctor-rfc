require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders areas" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :area: first_area, second_area
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      <area>first_area</area><area>second_area</area>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
