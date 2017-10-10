require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders an ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [start=3,group=5,arabic,spacing=compact]
      . First
      . Second
    INPUT
       <ol anchor="id" spacing="compact" start="3" group="5" type="1">
       <li>First</li>
       <li>Second</li>
       </ol>
    OUTPUT
  end

  it "ignores anchors on list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [start=3,group=5,arabic,spacing=compact]
      . First
      . [[id1]] Second
    INPUT
       <ol anchor="id" spacing="compact" start="3" group="5" type="1">
       <li>First</li>
       <li>Second</li>
       </ol>
    OUTPUT
  end

  it "renders a nested ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
       <ol anchor="id" type="a">
       <li>First</li>
       <li>Second
       <ol type="A">
       <li>Third</li>
       <li>Fourth</li>
       </ol>
       </li>
       <li>Fifth</li>
       <li>Sixth</li>
       </ol>
    OUTPUT
  end
  
  it "renders a nested ordered/unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [lowerroman]
      . First
      . Second
      ** Third
      ** Fourth
    INPUT
       <ol anchor="id" type="i">
       <li>First</li>
       <li>Second
       <ul>
       <li>Third</li>
       <li>Fourth</li>
       </ul>
       </li>
       </ol>
    OUTPUT
  end

  it "renders decimal lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [decimal]
      . First
      . Second
    INPUT
       <ol anchor="id" type="1">
       <li>First</li>
       <li>Second</li>
       </ol>
    OUTPUT
  end


  it "renders lowergreek lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [lowergreek]
      . First
      . Second
    INPUT
       <ol anchor="id" type="1">
       <li>First</li>
       <li>Second</li>
       </ol>
    OUTPUT
  end

  
  
end
