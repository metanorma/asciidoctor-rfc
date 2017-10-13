require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [hang-indent=5]
      A:: B
      C:: D
    INPUT
      <t>
      <list hangIndent="5" style="hanging">
      <t hangText="A">B</t>
      <t hangText="C">D</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders hybrid description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      Dairy::
      * Milk
      * Eggs
      Bakery::
      * Bread
      Produce::
      * Bananas
    INPUT
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
    OUTPUT
  end
end
