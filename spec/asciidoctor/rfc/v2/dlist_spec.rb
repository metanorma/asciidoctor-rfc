require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a description list" do
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
           <t hangText="A">B</t>
           <t hangText="C">D</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders hybrid description list" do
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
           <t hangText="Notes">Note 1.<vspace/>Note 2.
       <vspace/>Note 3.</t>
         </list>
       </t>
      </section>
    OUTPUT
  end
end
