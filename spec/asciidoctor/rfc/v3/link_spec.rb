require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders links" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :link: http://www.example.com,urn:issn:99999999 item

      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <link href="http://www.example.com"/>
      <link href="urn:issn:99999999" rel="item"/>
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
