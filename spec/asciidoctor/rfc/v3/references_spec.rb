require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders raw RFC XML as references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft

      == Text
      Text

      [bibliography]
      == References

      === Normative References
      ++++
      <reference anchor='ISO.IEC.10118-3' target='https://www.iso.org/standard/67116.html'>
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
      <section anchor="_text" numbered="false">
      <name>Text</name>
      <t>Text</t>
      </section>
      </middle><back>
      <references anchor="_references">
      <name>Normative References</name>
      <reference anchor='ISO.IEC.10118-3' target='https://www.iso.org/standard/67116.html'>
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
    OUTPUT
  end

  it "renders raw RFC XML as references, with displayreferences" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft

      == Text
      Text

      [bibliography]
      == References
      * [[[xxx,1]]]
      * [[[gof,2]]]

      === Normative References
      ++++
      <reference anchor='ISO.IEC.10118-3' target='https://www.iso.org/standard/67116.html'>
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
      <?xml version="1.0" encoding="US-ASCII"?>
       <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
       <?rfc strict="yes"?>
       <?rfc toc="yes"?>
       <?rfc tocdepth="4"?>
       <?rfc symrefs=""?>
       <?rfc sortrefs=""?>
       <?rfc compact="yes"?>
       <?rfc subcompact="no"?>
       <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title>Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

       </front><middle>
       <section anchor="_text" numbered="false">
         <name>Text</name>
         <t>Text</t>
       </section>
       </middle><back>
       <displayreference target="xxx" to="1"/>
       <displayreference target="gof" to="2"/>
       <references anchor="_normative_references">
         <name>Normative References</name>
         <reference anchor="ISO.IEC.10118-3" target="https://www.iso.org/standard/67116.html">  <front>    <title>ISO/IEC FDIS 10118-3 -- Information technology -- Security techniques -- Hash-functions -- Part 3: Dedicated hash-functions</title>    <author>      <organization>International Organization for Standardization</organization>      <address>        <postal>          <street>BIBC II</street>          <street>Chemin de Blandonnet 8</street>          <street>CP 401</street>          <city>Vernier</city>          <region>Geneva</region>          <code>1214</code>          <country>Switzerland</country>        </postal>        <phone>+41 22 749 01 11</phone>        <email>central@iso.org</email>        <uri>https://www.iso.org/</uri>      </address>    </author>    <date day="15" month="September" year="2017"/>  </front></reference>
       </references>
       </back>
      </rfc>
    OUTPUT
  end
end
