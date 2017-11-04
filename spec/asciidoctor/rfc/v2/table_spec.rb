require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [[id]]
      [suppress-title=false,align=left,grid=cols]
      .Table Title
      |===
      |[[id]] head | head

      h|header cell | body cell
      | | body cell
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell

      |foot | foot
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
      <ttcol align="left"> head</ttcol>
      <ttcol align="left">head</ttcol>
      <c>header cell</c>
      <c>body cell</c>
      <c></c>
      <c>body cell</c>
      <c>centre aligned cell</c>
      <c>cell</c>
      <c>left aligned cell</c>
      <c>cell</c>
      <c>right aligned cell</c>
      <c>cell</c>
      <c>foot</c>
      <c>foot</c>
      </texttable>
      </section>
    OUTPUT
  end

  it "ignores cell anchors in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [[id]]
      [suppress-title=false,align=left,grid=cols]
      .Table Title
      |===
      |[[id]] head | head

      h|header cell | body cell
      | | [[id]] body cell
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell

      |foot | foot
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
      <ttcol align="left"> head</ttcol>
      <ttcol align="left">head</ttcol>
      <c>header cell</c>
      <c>body cell</c>
      <c></c>
      <c> body cell</c>
      <c>centre aligned cell</c>
      <c>cell</c>
      <c>left aligned cell</c>
      <c>cell</c>
      <c>right aligned cell</c>
      <c>cell</c>
      <c>foot</c>
      <c>foot</c>
      </texttable>
      </section>
    OUTPUT
  end

  it "ignores colspan and rowspan in table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [[id]]
      [suppress-title=false,align=left,grid=cols]
      .Table Title
      |===
      |[[id]] head | head

      h|header cell | body cell
      | | body cell
      2+| colspan of 2
      .2+|rowspan of 2 | cell
      |cell
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell

      |foot | foot
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
      <ttcol align="left"> head</ttcol>
      <ttcol align="left">head</ttcol>
      <c>header cell</c>
      <c>body cell</c>
      <c></c>
      <c>body cell</c>
      <c>colspan of 2</c>
      <c>rowspan of 2</c>
      <c>cell</c>
      <c>cell</c>
      <c>centre aligned cell</c>
      <c>cell</c>
      <c>left aligned cell</c>
      <c>cell</c>
      <c>right aligned cell</c>
      <c>cell</c>
      <c>foot</c>
      <c>foot</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders inline formatting within a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      .Table Title
      |===
      |head | head

      h|header cell | *body* _cell_
      | | body cell<<x>>
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell

      |foot | foot
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable title="Table Title" suppress-title="false" style="full">
         <ttcol align="left">head</ttcol>
         <ttcol align="left">head</ttcol>
         <c>header cell</c>
         <c><spanx style="strong">body</spanx> <spanx style="emph">cell</spanx></c>
         <c/>
         <c>body cell<xref target="x"/></c>
         <c>centre aligned cell</c>
         <c>cell</c>
         <c>left aligned cell</c>
         <c>cell</c>
         <c>right aligned cell</c>
         <c>cell</c>
         <c>foot</c>
         <c>foot</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "ignores block formatting within a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [cols="2"]
      .Table Title
      |===
      |head | head

      h|header cell
      a|
      * List 1
      * List 2
      | | body cell<<x>>
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell

      |foot | foot
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable title="Table Title" suppress-title="false" style="full">
         <ttcol align="left">head</ttcol>
         <ttcol align="left">head</ttcol>
         <c>header cell</c>
         <c>* List 1
       * List 2</c>
         <c/>
         <c>body cell<xref target="x"/></c>
         <c>centre aligned cell</c>
         <c>cell</c>
         <c>left aligned cell</c>
         <c>cell</c>
         <c>right aligned cell</c>
         <c>cell</c>
         <c>foot</c>
         <c>foot</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders relative column widths in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [cols="1,2,5"]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="full">
         <ttcol align="left" width="12.5%">a</ttcol>
         <ttcol align="left" width="25%">b</ttcol>
         <ttcol align="left" width="62.5%">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders percentage column widths in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [cols="10%,20%,70%"]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="full">
         <ttcol align="left" width="10%">a</ttcol>
         <ttcol align="left" width="20%">b</ttcol>
         <ttcol align="left" width="70%">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "ignores '1,1,1,1,...' column widths in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [cols="1,1,1"]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="full">
         <ttcol align="left">a</ttcol>
         <ttcol align="left">b</ttcol>
         <ttcol align="left">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders table with grid=all" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [grid=all]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="all">
         <ttcol align="left">a</ttcol>
         <ttcol align="left">b</ttcol>
         <ttcol align="left">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders table with grid=rows" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [grid=rows]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="none">
         <ttcol align="left">a</ttcol>
         <ttcol align="left">b</ttcol>
         <ttcol align="left">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders table with grid=cols" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [grid=cols]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="full">
         <ttcol align="left">a</ttcol>
         <ttcol align="left">b</ttcol>
         <ttcol align="left">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
  it "renders table with grid=none" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [grid=none]
      |===
      |a |b |c

      |a |b |c
      |===
    INPUT
      <section anchor="_section_1" title="Section 1">
      <texttable suppress-title="false" style="none">
         <ttcol align="left">a</ttcol>
         <ttcol align="left">b</ttcol>
         <ttcol align="left">c</ttcol>
         <c>a</c>
         <c>b</c>
         <c>c</c>
      </texttable>
      </section>
    OUTPUT
  end
end
