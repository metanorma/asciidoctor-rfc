require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders workgroups" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :workgroup: first_workgroup, second_workgroup

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      <workgroup>first_workgroup</workgroup>
      <workgroup>second_workgroup</workgroup>
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
