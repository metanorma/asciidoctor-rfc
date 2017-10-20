require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders links" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      http://example.com/
      http://example.com/[linktext]
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t><eref target="http://example.com/"></eref>
      <eref target="http://example.com/">linktext</eref></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders cross-references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[crossreference]]
      == Section 1

      == Section 2
      See <<crossreference>>.

      == Section 3
      See <<crossreference,text>>

      == Section 4
      See <<crossreference,format=counter: text>>
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="crossreference" title="Section 1">
      </section>
      <section anchor="_section_2" title="Section 2">
      <t>See <xref target="crossreference"></xref>.</t>
      </section>
      <section anchor="_section_3" title="Section 3">
      <t>See <xref target="crossreference">text</xref></t>
      </section>
      <section anchor="_section_4" title="Section 4">
      <t>See <xref format="counter" target="crossreference">text</xref></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders cross-references to bibliography" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1

      == Section 2
      See <<crossreference>>.

      == Section 3
      See <<crossreference,text>>

      [bibliography]
      == References
      ++++
      <reference anchor='crossreference' target='https://tools.ietf.org/html/rfc7253'>
      <front>
         <title>Guidelines for Writing an IANA Considerations Section in RFCs</title>
         <author initials="T." surname="Krovetz">
           <organization>Sacramento State</organization>
         </author>
         <date month='May' year='2014'/>
      </front>
      </reference>
      ++++
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      </section>
      <section anchor="_section_2" title="Section 2">
      <t>See <xref target="crossreference"></xref>.</t>
      </section>
      <section anchor="_section_3" title="Section 3">
      <t>See <xref target="crossreference">text</xref></t>
      </section>
      </middle><back>
      <references title="References">
      <reference anchor='crossreference' target='https://tools.ietf.org/html/rfc7253'>
       <front>
         <title>Guidelines for Writing an IANA Considerations Section in RFCs</title>
         <author initials="T." surname="Krovetz">
           <organization>Sacramento State</organization>
         </author>
         <date month='May' year='2014'/>
       </front>
      </reference>
      </references>
      </back>
      </rfc>
    OUTPUT
  end
  it "renders relref references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      See <<crossreference,1.3 of>>
      <<crossreference,1.4 comma: text>>
      <<crossreference#fragment1,2.5.3 parens>>
      <<crossreference#fragment2,6.2a bare: text>>

      [bibliography]
      == References
      ++++
      <reference anchor='crossreference' target='https://www.iso.org/standard/67116.html'>
        <front>
          <title>ISO/IEC FDIS 10118-3 -- Information technology -- Security techniques -- Hash-functions -- Part 3: Dedicated hash-functions</title>
          <author>
            <organization>International Organization for Standardization</organization>
            <address>
              <postal>
                <street>BIBC II</street>
                <street>Chemin de Blandonnet 8</street>
                <street>CP 401</street>
                <city>Vernier</city>
                <region>Geneva</region>
                <code>1214</code>
                <country>Switzerland</country>
              </postal>
              <phone>+41 22 749 01 11</phone>
              <email>central@iso.org</email>
              <uri>https://www.iso.org/</uri>
            </address>
          </author>
          <date day='15' month='September' year='2017'/>
        </front>
      </reference>
      ++++
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc submissionType="IETF">
       <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>See <xref target="crossreference">Section 1.3 of [crossreference]</xref>
       <xref target="crossreference">[crossreference], Section 1.4</xref>
       <xref target="crossreference#fragment1">[crossreference] (Section 2.5.3)</xref>
       <xref target="crossreference#fragment2">6.2a</xref></t>
       </section>
       </middle><back>
       <references title="References">
         <reference anchor="crossreference" target="https://www.iso.org/standard/67116.html">  <front>    <title>ISO/IEC FDIS 10118-3 -- Information technology -- Security techniques -- Hash-functions -- Part 3: Dedicated hash-functions</title>    <author>      <organization>International Organization for Standardization</organization>      <address>        <postal>          <street>BIBC II</street>          <street>Chemin de Blandonnet 8</street>          <street>CP 401</street>          <city>Vernier</city>          <region>Geneva</region>          <code>1214</code>          <country>Switzerland</country>        </postal>        <phone>+41 22 749 01 11</phone>        <email>central@iso.org</email>        <uri>https://www.iso.org/</uri>      </address>    </author>    <date day="15" month="September" year="2017"/>  </front></reference>
       </references>
      </back>
      </rfc>
    OUTPUT
  end
end
