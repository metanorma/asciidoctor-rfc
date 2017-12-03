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

  it "renders external RFC XML references as includes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true).to_s).to be_equivalent_to <<~'OUTPUT'
      = The Holy Hand Grenade of Antioch
      Arthur Pendragon
      :doctype: internet-draft

      == Hello
      Hello

      [bibliography]
      == Normative References
      ++++
      <reference anchor="RFC2119" target="https://www.rfc-editor.org/info/rfc2119">
      <front>
      <title>
      Key words for use in RFCs to Indicate Requirement Levels
      </title>
      <author initials="S." surname="Bradner" fullname="S. Bradner">
      <organization/>
      </author>
      <date year="1997" month="March"/>
      <abstract>
      <t>
      In many standards track documents several words are used to signify the requirements in the specification. These words are often capitalized. This document defines these words as they should be interpreted in IETF documents. This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.
      </t>
      </abstract>
      </front>
      <seriesInfo name="BCP" value="14"/>
      <seriesInfo name="RFC" value="2119"/>
      <seriesInfo name="DOI" value="10.17487/RFC2119"/>
      </reference>
      ++++

      [bibliography]
      == Informative References
      ++++
      <reference anchor="I-D.abarth-cake">
      <front>
      <title>Simple HTTP State Management Mechanism</title>
      <author initials="A" surname="Barth" fullname="Adam Barth">
      <organization/>
      </author>
      <date month="August" day="22" year="2010"/>
      <abstract>
      <t>
      This document describes a simple HTTP state management mechanism, called cake, that lets HTTP servers maintain stateful sessions with HTTP user agents. This mechanism is harmonized with the same-origin security model and provides both confidentiality and integrity protection against active network attackers. In addition, the mechanism is robust to cross-site request forgery attacks.Editorial Note (To be removed by RFC Editor) If you have suggestions for improving this document, please send email to mailto:http-state@ietf.org. Further Working Group information is available from https://tools.ietf.org/wg/httpstate/.
      </t>
      </abstract>
      </front>
      <seriesInfo name="Internet-Draft" value="draft-abarth-cake-00"/>
      <format type="TXT" target="http://www.ietf.org/internet-drafts/draft-abarth-cake-00.txt"/>
      </reference>
      ++++
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title>The Holy Hand Grenade of Antioch</title>
         <author fullname="Arthur Pendragon" surname="Pendragon"/>
         <date day="1" month="January" year="2000"/>
       </front><middle>
       <section anchor="_hello" numbered="false">
         <name>Hello</name>
         <t>Hello</t>
       </section>
       </middle><back>
       <references anchor="_normative_references">
         <name>Normative References</name>
         <xi:include href="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2119.xml" parse="text"/>
       </references>
       <references anchor="_informative_references">
         <name>Informative References</name>
         <xi:include href="https://xml2rfc.tools.ietf.org/public/rfc/bibxml3//reference.I-D.draft-abarth-cake-00.xml" parse="text"/>
       </references>
       </back>
      </rfc>
    OUTPUT
  end

  it "renders skeletal external RFC XML references as includes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true).to_s).to be_equivalent_to <<~'OUTPUT'
      = The Holy Hand Grenade of Antioch
      Arthur Pendragon
      :doctype: internet-draft

      == Hello
      Hello

      [bibliography]
      == Normative References
      ++++
      <reference anchor="RFC2119" target="https://www.rfc-editor.org/info/rfc2119">
      <front>
      <title/>
      <author/>
      <date/>
      </front>
      </reference>
      ++++

      [bibliography]
      == Informative References
      ++++
      <reference anchor="I-D.abarth-cake">
      <front>
      <title/>
      <author/>
      <date/>
      </front>
      </reference>
      ++++
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title>The Holy Hand Grenade of Antioch</title>
         <author fullname="Arthur Pendragon" surname="Pendragon"/>
         <date day="1" month="January" year="2000"/>

       </front><middle>
       <section anchor="_hello" numbered="false">
         <name>Hello</name>
         <t>Hello</t>
       </section>
       </middle><back>
       <references anchor="_normative_references">
         <name>Normative References</name>
         <xi:include href="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2119.xml" parse="text"/>
       </references>
       <references anchor="_informative_references">
         <name>Informative References</name>
          <xi:include href="https://xml2rfc.tools.ietf.org/public/rfc/bibxml3//reference.I-D.abarth-cake.xml" parse="text"/>
       </references>
       </back>
      </rfc>
    OUTPUT
  end

  it "renders skeletal external RFC XML references with drafts as includes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true).to_s).to be_equivalent_to <<~'OUTPUT'
      = The Holy Hand Grenade of Antioch
      Arthur Pendragon
      :doctype: internet-draft

      == Hello
      Hello

      [bibliography]
      == Informative References
      ++++
      <reference anchor="I-D.abarth-cake">
      <front>
      <title/>
      <author/>
      <date/>
      </front>
      <seriesInfo name="Internet-Draft" value="draft-abarth-cake-00"/>
      </reference>
      ++++
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
         <title>The Holy Hand Grenade of Antioch</title>
         <author fullname="Arthur Pendragon" surname="Pendragon"/>
         <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_hello" numbered="false">
         <name>Hello</name>
         <t>Hello</t>
       </section>
       </middle><back>
       <references anchor="_informative_references">
          <name>Informative References</name>
          <xi:include href="https://xml2rfc.tools.ietf.org/public/rfc/bibxml3//reference.I-D.draft-abarth-cake-00.xml" parse="text"/>
       </references>
       </back>
       </rfc>
    OUTPUT
  end
end
