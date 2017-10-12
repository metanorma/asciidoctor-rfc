require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "renders author, date, area, workgroup, keyword in sequence" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
        <rfc
                 submissionType="IETF" docName="rfc-1111">
        <front>
        <title abbrev="abbrev_value">Document title</title>
        <author fullname="Author"/>
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
