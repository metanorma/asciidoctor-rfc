require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a definition list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [[id]]
      [hang-indent=5]
      A:: B
      C:: D
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list hangIndent="5" style="hanging">
           <t hangText="A"><vspace blankLines="1"/>B</t>
           <t hangText="C"><vspace blankLines="1"/>D</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders an inline definition list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :inline-definition-list: true

      == Section 1
      [[id]]
      [hang-indent=5]
      A:: B
      C:: D
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
      <?rfc strict="yes"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <rfc submissionType="IETF">
      <front>
         <title>Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>
         <list hangIndent="5" style="hanging">
           <t hangText="A"><vspace blankLines="0"/>B</t>
           <t hangText="C"><vspace blankLines="0"/>D</t>
         </list>
       </t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores formatting on definition list terms" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      `A` _2_:: B
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="A 2"><vspace blankLines="1"/>B</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders a definition list with empty style" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [[id]]
      [empty,hang-indent=5]
      A:: B
      C:: D
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list hangIndent="5" style="empty">
           <t hangText="A"><vspace blankLines="1"/>B</t>
           <t hangText="C"><vspace blankLines="1"/>D</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders hybrid definition list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      Dairy::
      * Milk
      * Eggs
      Bakery::
      * Bread
      Produce::
      * Bananas
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="Dairy">
             <list style="symbols">
         <t>Milk</t>
         <t>Eggs</t>
       </list>
           </t>
           <t hangText="Bakery">
             <list style="symbols">
         <t>Bread</t>
       </list>
           </t>
           <t hangText="Produce">
             <list style="symbols">
         <t>Bananas</t>
       </list>
           </t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders a definition list with definitions on the next line" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      A::
      +
      B
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="A"><vspace blankLines="1"/>B</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "uses vspace to break up multi paragraph list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="Notes"><vspace blankLines="1"/>Note 1.<vspace blankLines="1"/>Note 2.
       <vspace blankLines="1"/>Note 3.</t>
         </list>
       </t>
      </section>
    OUTPUT
  end
  it "renders definition lists with more definition terms than definitions" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      Notes1::
      Notes2:: Definition
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="Notes1"/>
           <t hangText="Notes2"><vspace blankLines="1"/>Definition</t>
         </list>
       </t>
      </section>
    OUTPUT
  end
end
