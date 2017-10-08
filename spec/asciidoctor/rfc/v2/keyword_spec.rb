require "spec_helper"

xdescribe Asciidoctor::RFC::V2::Converter do
  it "renders keywords" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :keyword: first_keyword, second_keyword
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author">
      </author>

      <keyword>first_keyword</keyword>
      <keyword>second_keyword</keyword>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
