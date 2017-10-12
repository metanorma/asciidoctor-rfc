require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "renders a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
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
        <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
        <ttcol align="left" width="50%"> head</ttcol>
        <ttcol align="left" width="50%">head</ttcol>
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
    OUTPUT
  end
  
  it "ignores cell anchors in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
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
        <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
        <ttcol align="left" width="50%"> head</ttcol>
        <ttcol align="left" width="50%">head</ttcol>
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
    OUTPUT
  end
  
    it "ignores colspan and rowspan in table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
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
        <texttable anchor="id" title="Table Title" suppress-title="false" align="left" style="full">
        <ttcol align="left" width="50%"> head</ttcol>
        <ttcol align="left" width="50%">head</ttcol>
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
    OUTPUT
  end
  
end
