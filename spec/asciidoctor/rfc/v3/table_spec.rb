require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
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
      <table anchor="id">
      <name>Table Title</name>
      <thead>
      <tr>
      <th align="left"> head</th>
      <th align="left">head</th>
      </tr>
      </thead>
      <tbody>
      <tr>
      <th align="left">header cell</th>
      <td align="left">body cell</td>
      </tr>
      <tr>
      <td align="left"></td>
      <td align="left">body cell</td>
      </tr>
      <tr>
      <td colspan="2" align="left">colspan of 2</td>
      </tr>
      <tr>
      <td rowspan="2" align="left">rowspan of 2</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="center">centre aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">left aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="right">right aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">foot</td>
      <td align="left">foot</td>
      </tr>
      </tbody>
      </table>
    OUTPUT
  end
  it "ignores cell anchors in a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Table Title
      |===
      |[[id]] head | head

      h|header cell | body cell
      | | [[id]] body cell
      2+| colspan of 2
      .2+|rowspan of 2 | cell
      |cell
      ^|centre aligned cell | cell
      <|left aligned cell | cell
      >|right aligned cell | cell
      |foot | foot
      |===
    INPUT
      <table anchor="id">
      <name>Table Title</name>
      <thead>
      <tr>
      <th align="left"> head</th>
      <th align="left">head</th>
      </tr>
      </thead>
      <tbody>
      <tr>
      <th align="left">header cell</th>
      <td align="left">body cell</td>
      </tr>
      <tr>
      <td align="left"></td>
      <td align="left"> body cell</td>
      </tr>
      <tr>
      <td colspan="2" align="left">colspan of 2</td>
      </tr>
      <tr>
      <td rowspan="2" align="left">rowspan of 2</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="center">centre aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">left aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="right">right aligned cell</td>
      <td align="left">cell</td>
      </tr>
      <tr>
      <td align="left">foot</td>
      <td align="left">foot</td>
      </tr>
      </tbody>
      </table>
    OUTPUT
  end
  it "renders inline formatting within a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
      <table>
         <name>Table Title</name>
         <thead>
           <tr>
             <th align="left">head</th>
             <th align="left">head</th>
           </tr>
         </thead>
         <tbody>
           <tr>
             <th align="left">header cell</th>
             <td align="left"><strong>body</strong> <em>cell</em></td>
           </tr>
           <tr>
             <td align="left"/>
             <td align="left">body cell<xref target="x"/></td>
           </tr>
           <tr>
             <td align="center">centre aligned cell</td>
             <td align="left">cell</td>
           </tr>
           <tr>
             <td align="left">left aligned cell</td>
             <td align="left">cell</td>
           </tr>
           <tr>
             <td align="right">right aligned cell</td>
             <td align="left">cell</td>
           </tr>
           <tr>
             <td align="left">foot</td>
             <td align="left">foot</td>
           </tr>
         </tbody>
      </table>
    OUTPUT
  end
  it "renders block formatting within a table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
end
