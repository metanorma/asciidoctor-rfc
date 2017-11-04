require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "rejects an unordered list of references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft

      == Text
      Text

      [[id]]
      [bibliography]
      == References
      * [[[xxx]]] Andy Hunt & Dave Thomas. The Pragmatic Programmer:
         From Journeyman to Master. Addison-Wesley. 1999.
      * [[[gof]]] Erich Gamma, Richard Helm, Ralph Johnson & John Vlissides. Design Patterns:
         Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.
    INPUT
      <section anchor="_text" title="Text">
      <t>Text</t>
      </section>
      </middle><back>
      <references title="References">
      </references>
    OUTPUT
  end

  it "renders raw RFC XML as references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
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
      <section anchor="_text" title="Text">
      <t>Text</t>
      </section>
      <references title="Normative References">
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
end
