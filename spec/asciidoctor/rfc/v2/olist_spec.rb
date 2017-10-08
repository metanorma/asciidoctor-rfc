require "spec_helper"

xdescribe Asciidoctor::RFC::V2::Converter do
  it "renders a description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [horizontal, compact]
      A:: B
      C:: D
    INPUT
      <dl anchor="id">
      <dt>A</dt>
      <dd>B</dd>
      <dt>C</dt>
      <dd>D</dd>
      </dl>
    OUTPUT
  end
end
