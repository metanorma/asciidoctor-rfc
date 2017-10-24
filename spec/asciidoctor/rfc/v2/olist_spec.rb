require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders an ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [counter=idx,arabic]
      . First
      . Second
    INPUT
      <t>
      <list counter="idx" style="numbers">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "ignores anchors on ordered list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [counter=idx,group=5,arabic,spacing=compact]
      . First
      . [[id1]] Second
    INPUT
      <t>
      <list counter="idx" style="numbers">
      <t>First</t>
      <t> Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders an ordered list with empty style" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [empty]
      . First
      . Second
    INPUT
      <t>
      <list style="empty">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders an ordered list with custom style" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [format="#%d"]
      . First
      . Second
    INPUT
      <t>
      <list style="format #%d">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders a nested ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [loweralpha]
      . First
      . Second
      [upperalpha]
      .. Third
      .. Fourth
      . Fifth
      . Sixth
    INPUT
      <t>
      <list style="letters">
      <t>First</t>
      <t>Second
      <list style="format %C.">
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
      [lowerroman]
      . First
      . Second
      ** Third
      ** Fourth
    INPUT
      <t>
      <list style="format %i.">
      <t>First</t>
      <t>Second
      <list style="symbols">
      <t>Third</t>
      <t>Fourth</t>
      </list>
      </t>
      </list>
      </t>
    OUTPUT
  end

  it "renders decimal lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [decimal]
      . First
      . Second
    INPUT
      <t>
      <list style="numbers">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end

  it "renders lowergreek lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [lowergreek]
      . First
      . Second
    INPUT
      <t>
      <list style="numbers">
      <t>First</t>
      <t>Second</t>
      </list>
      </t>
    OUTPUT
  end
end
