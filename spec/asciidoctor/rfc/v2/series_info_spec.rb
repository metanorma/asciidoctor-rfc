require "spec_helper"

xdescribe Asciidoctor::RFC::V2::Converter do
  it "renders defaults if docName is empty" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :status: status_value
      :stream: stream_value
      :docName:
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" stream="IETF" value="000000"/>
      <seriesInfo name="" value="000000"/>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
