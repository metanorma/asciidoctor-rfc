require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders links" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      http://example.com/
      http://example.com/[linktext]
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t><eref target="http://example.com/"></eref>
      <eref target="http://example.com/">linktext</eref></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders cross-references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="crossreference" numbered="false">
      <name>Section 1</name>
      </section>
      <section anchor="_section_2" numbered="false">
      <name>Section 2</name>
      <t>See <xref target="crossreference"></xref>.</t>
      </section>
      <section anchor="_section_3" numbered="false">
      <name>Section 3</name>
      <t>See <xref target="crossreference">text</xref></t>
      </section>
      <section anchor="_section_4" numbered="false">
      <name>Section 4</name>
      <t>See <xref format="counter" target="crossreference">text</xref></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders cross-references to bibliography" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      </section>
      <section anchor="_section_2" numbered="false">
      <name>Section 2</name>
      <t>See <xref target="crossreference"></xref>.</t>
      </section>
      <section anchor="_section_3" numbered="false">
      <name>Section 3</name>
      <t>See <xref target="crossreference">text</xref></t>
      </section>
      </middle><back>
      <references anchor="_references">
      <name>References</name>
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
      </references>
      </back>
      </rfc>
    OUTPUT
  end
  it "renders relref references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>See <relref section="1.3" displayFormat="of" target="crossreference"></relref>
      <relref section="1.4" displayFormat="comma" target="crossreference">text</relref>
      <relref relative="fragment1" section="2.5.3" displayFormat="parens" target="crossreference"></relref>
      <relref relative="fragment2" section="6.2a" displayFormat="bare" target="crossreference">text</relref></t>
      </section>
      </middle><back>
      <references anchor="_references">
      <name>References</name>
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
      </references>
      </back>
      </rfc>
    OUTPUT
  end
end
