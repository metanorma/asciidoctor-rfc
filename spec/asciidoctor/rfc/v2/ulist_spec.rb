require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders an unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
    INPUT
      <t>
      <list style="symbols">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "ignores anchors on list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * [[id1]] Second
    INPUT
      <t>
      <list style="symbols">
      <t>First</t>
      <t> Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders a nested unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      ** Third
      ** Fourth
      * Fifth
      * Sixth
    INPUT
      <t>
      <list style="symbols">
      <t>First</t>
      <t>Second
      <list style="symbols">
      <t>Third</t>
      <t>Fourth</t>
      </list>
      </t>
      <t>Fifth</t>
      <t>Sixth</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders a nested ordered/unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      [lowerroman]
      .. Third
      .. Fourth
    INPUT
      <t>
      <list style="symbols">
      <t>First</t>
      <t>Second
      <list style="format %i">
      <t>Third</t>
      <t>Fourth</t>
      </list>
      </t>
      </list>
      </t>
    OUTPUT
  end
end
