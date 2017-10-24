require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders an ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [[id]]
      [start=3,group=5,arabic,spacing=compact]
      . First
      . Second
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" spacing="compact" start="3" group="5" type="1">
      <li>First</li>
      <li>Second</li>
      </ol>
      </section>
    OUTPUT
  end
  it "ignores anchors on list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [[id]]
      [start=3,group=5,arabic,spacing=compact]
      . First
      . [[id1]] Second
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" spacing="compact" start="3" group="5" type="1">
      <li>First</li>
      <li>Second</li>
      </ol>
      </section>
    OUTPUT
  end
  it "renders an ordered list with custom style" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [format="#%d"]
      . First
      . Second
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol type="#%d">
      <li>First</li>
      <li>Second</li>
      </ol>
      </section>
    OUTPUT
  end
  it "renders a nested ordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
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
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" type="a">
      <li>First</li>
      <li><t>Second</t>
      <ol type="A">
      <li>Third</li>
      <li>Fourth</li>
      </ol>
      </li>
      <li>Fifth</li>
      <li>Sixth</li>
      </ol>
      </section>
    OUTPUT
  end
  it "renders a nested ordered/unordered list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [[id]]
      [lowerroman]
      . First
      . Second
      ** Third
      ** Fourth
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" type="i">
      <li>First</li>
      <li><t>Second</t>
      <ul>
      <li>Third</li>
      <li>Fourth</li>
      </ul>
      </li>
      </ol>
      </section>
    OUTPUT
  end
  it "renders decimal lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [[id]]
      [decimal]
      . First
      . Second
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" type="1">
      <li>First</li>
      <li>Second</li>
      </ol>
      </section>
    OUTPUT
  end
  it "renders lowergreek lists as arabic" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      [[id]]
      [lowergreek]
      . First
      . Second
    INPUT
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <ol anchor="id" type="1">
      <li>First</li>
      <li>Second</li>
      </ol>
      </section>
    OUTPUT
  end
end
