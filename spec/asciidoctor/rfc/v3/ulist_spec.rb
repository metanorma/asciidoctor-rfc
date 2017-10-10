require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders an unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [empty=true,spacing=compact]
      * First
      * Second
    INPUT
       <ul anchor="id" empty="true" spacing="compact">
       <li>First</li>
       <li>Second</li>
       </ul>
    OUTPUT
  end

  it "ignores anchors on list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * [[id1]] Second
    INPUT
       <ul anchor="id">
       <li>First</li>
       <li> Second</li>
       </ul>
    OUTPUT
  end

  it "renders a nested unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      ** Third
      ** Fourth
      * Fifth
      * Sixth
    INPUT
       <ul anchor="id">
       <li>First</li>
       <li>Second
       <ul>
       <li>Third</li>
       <li>Fourth</li>
       </ul>
       </li>
       <li>Fifth</li>
       <li>Sixth</li>
       </ul>
    OUTPUT
  end
  
  it "renders a nested ordered/unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      [lowerroman]
      .. Third
      .. Fourth
    INPUT
       <ul anchor="id">
       <li>First</li>
       <li>Second
       <ol type="i">
       <li>Third</li>
       <li>Fourth</li>
       </ol>
       </li>
       </ul>
    OUTPUT
  end

end
