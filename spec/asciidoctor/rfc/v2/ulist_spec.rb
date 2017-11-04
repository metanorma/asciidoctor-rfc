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

  it "ignores anchors on unordered list items" do
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

  it "renders an unordered list with empty style" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [empty]
      * First
      * Second
    INPUT
      <t>
      <list style="empty">
      <t>First</t>
      <t>Second</t>
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
      <list style="format %i.">
      <t>Third</t>
      <t>Fourth</t>
      </list>
      </t>
      </list>
      </t>
    OUTPUT
  end

  it "renders a nested list containing a literal" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      +
      ....
      <entry>
      ....
    INPUT
      <t>
         <list style="symbols">
           <t>First</t>
           <t>Second<figure>
         <artwork>&lt;entry&gt;</artwork>
       </figure></t>
         </list>
      </t>
    OUTPUT
  end
  
  it "renders a nested list containing a comment" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      * First
      * Second
      +
      NOTE: Note
    INPUT
      <t>
         <list style="symbols">
           <t>First</t>
           <t>Second<vspace blankLines="1"/>
           <cref>Note</cref>
           </t>
         </list>
      </t>
    OUTPUT
  end
end
