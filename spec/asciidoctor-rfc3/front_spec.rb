require "spec_helper"

describe Asciidoctor::Rfc3::Converter do
  it "renders title and abbrev" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>

      <title abbrev="abbrev_value">Document title</title>

      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
