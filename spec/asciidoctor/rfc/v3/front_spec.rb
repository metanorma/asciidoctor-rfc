require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders series, author, date, area, workgroup, keyword in sequence" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :abbrev: abbrev_value
      :name: rfc-1111
      :revdate: 1999-01-01
      :area: horticulture
      :workgroup: IETF
      :keyword: widgets
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <seriesInfo name="RFC" stream="IETF" value="1111"/>
       <author fullname="Author">
       </author>
       <date day="1" month="January" year="1999"/>
       <area>horticulture</area>
       <workgroup>IETF</workgroup>
       <keyword>widgets</keyword>
       </front><middle>
       </middle>
       </rfc>
    OUTPUT
  end


end
