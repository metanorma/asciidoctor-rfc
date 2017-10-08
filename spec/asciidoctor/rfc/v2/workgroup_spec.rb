require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders workgroups" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :workgroup: first_workgroup, second_workgroup
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author">
      </author>

      <workgroup>first_workgroup</workgroup>
      <workgroup>second_workgroup</workgroup>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
