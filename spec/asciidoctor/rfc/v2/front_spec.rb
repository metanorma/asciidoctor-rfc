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
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

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
      <section anchor="_section_1" title="Section 1">
     
         <t>text</t>
     
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "deals with entities in titles" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document on the derivation of x & y < z
      Author
      :abbrev: deriv x & y < z
      :name: rfc-1111
      :revdate: 1999-01-01
      :area: horticulture
      :workgroup: IETF
      :keyword: widgets
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF" docName="rfc-1111">
      <front>
      <title abbrev="deriv x &amp; y &lt; z">Document on the derivation of x &amp; y &lt; z</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1999"/>
      <area>horticulture</area>
      <workgroup>IETF</workgroup>
      <keyword>widgets</keyword>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
     
         <t>text</t>
     
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
