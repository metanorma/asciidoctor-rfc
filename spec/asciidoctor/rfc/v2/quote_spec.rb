require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a quote as a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [quote, attribution="quote attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
      <t anchor="verse-id">Text</t>
    OUTPUT
  end

  it "renders a verse" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [verse, Carl Sandburg, two lines from the poem Fog]
      The fog comes
      on little cat feet.
    INPUT
      <t anchor="verse-id">The fog comes<br/>
      on little cat feet.</t>
    OUTPUT
  end
end
