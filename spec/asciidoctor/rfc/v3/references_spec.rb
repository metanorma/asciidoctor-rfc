require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders an unordered list of references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
       <section anchor="_text" numbered="false">
       <name>Text</name>
       <t>Text</t>
       </section>
       </middle><back>
       <references anchor="id">
       <name>References</name>
       <reference anchor="xxx"><refcontent>Andy Hunt &amp; Dave Thomas. The Pragmatic Programmer:
       From Journeyman to Master. Addison-Wesley. 1999.</refcontent></reference>
       <reference anchor="gof"><refcontent>Erich Gamma, Richard Helm, Ralph Johnson &amp; John Vlissides. Design Patterns:
       Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.</refcontent></reference>
       </references>
    OUTPUT
  end

  it "renders an unordered list of references, with referencegroups" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft

      == Text
      Text

      [bibliography]
      == References
      * [[[pp]]]
      ** [[[xxx]]] Andy Hunt & Dave Thomas. The Pragmatic Programmer:
         From Journeyman to Master. Addison-Wesley. 1999.
      ** [[[xxxx]]] Personal communication.
      * [[[gof]]] Erich Gamma, Richard Helm, Ralph Johnson & John Vlissides. Design Patterns:
         Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.
    INPUT
       <section anchor="_text" numbered="false">
       <name>Text</name>
       <t>Text</t>
       </section>
       <references anchor="_references">
       <name>References</name>
       <referencegroup anchor="pp">
       <reference anchor="xxx"><refcontent>Andy Hunt &amp; Dave Thomas. The Pragmatic Programmer:
       From Journeyman to Master. Addison-Wesley. 1999.</refcontent></reference>
       <reference anchor="xxxx"><refcontent>Personal communication.</refcontent></reference>
       </referencegroup>
       <reference anchor="gof"><refcontent>Erich Gamma, Richard Helm, Ralph Johnson &amp; John Vlissides. Design Patterns:
       Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.</refcontent></reference>
       </references>
    OUTPUT
  end

  it "renders an unordered list of references, with displayreferences" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft

      == Text
      Text

      [bibliography]
      == References
      * [[[xxx,1]]] Andy Hunt & Dave Thomas. The Pragmatic Programmer:
         From Journeyman to Master. Addison-Wesley. 1999.
      * [[[gof,2]]] Erich Gamma, Richard Helm, Ralph Johnson & John Vlissides. Design Patterns:
         Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.
    INPUT
       <section anchor="_text" numbered="false">
       <name>Text</name>
       <t>Text</t>
       </section>
       <displayreference target="xxx" to="1"/>
       <displayreference target="gof" to="2"/>
       <references anchor="_references">
       <name>References</name>
       <reference anchor="xxx"><refcontent>Andy Hunt &amp; Dave Thomas. The Pragmatic Programmer:
       From Journeyman to Master. Addison-Wesley. 1999.</refcontent></reference>
       <reference anchor="gof"><refcontent>Erich Gamma, Richard Helm, Ralph Johnson &amp; John Vlissides. Design Patterns:
       Elements of Reusable Object-Oriented Software. Addison-Wesley. 1994.</refcontent></reference>
       </references>
    OUTPUT
  end


end
