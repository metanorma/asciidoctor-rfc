require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders a horizontal description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [horizontal]
      A:: B
      C:: D
    INPUT
      <dl anchor="id" hanging="true">
      <dt>A</dt>
      <dd>B</dd>
      <dt>C</dt>
      <dd>D</dd>
      </dl>
    OUTPUT
  end
  
  it "renders a compact description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [compact]
      A:: B
      C:: D
    INPUT
      <dl anchor="id" spacing="compact">
      <dt>A</dt>
      <dd>B</dd>
      <dt>C</dt>
      <dd>D</dd>
      </dl>
    OUTPUT
  end
  
  it "renders hybrid description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'  
       Dairy::
       * Milk
       * Eggs
       Bakery::
       * Bread
       Produce::
       * Bananas
    INPUT
       <dl>
       <dt>Dairy</dt>
       <dd>
       <ul>
       <li>Milk</li>
       <li>Eggs</li>
       </ul>
       </dd>
       <dt>Bakery</dt>
       <dd>
       <ul>
       <li>Bread</li>
       </ul>
       </dd>
       <dt>Produce</dt>
       <dd>
       <ul>
       <li>Bananas</li>
       </ul>
       </dd>
       </dl>
    OUTPUT
  end
  
  

end
