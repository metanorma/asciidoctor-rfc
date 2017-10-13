require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a listing" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename
      [align=left,alt=alt_text,type=abnf]
      ....
        Literal contents.
      ....
    INPUT
      <figure>
      <artwork anchor="literal-id" align="left" name="filename" type="abnf" alt="alt_text">
        Literal contents.
      </artwork>
      </figure>
    OUTPUT
  end

  it "ignores callouts" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename
      [align=left,alt=alt_text]
      ....
        Literal contents.
      ....
      <1> This is a callout
    INPUT
      <figure>
      <artwork anchor="literal-id" align="left" name="filename" alt="alt_text">
        Literal contents.
      </artwork>
      </figure>
    OUTPUT
  end

  it "renders stem as a literal" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      :stem:
      [stem]
      ++++
      sqrt(4) = 2
      ++++
    INPUT
      <figure>
      <artwork>
      sqrt(4) = 2
      </artwork>
      </figure>
    OUTPUT
  end
end
