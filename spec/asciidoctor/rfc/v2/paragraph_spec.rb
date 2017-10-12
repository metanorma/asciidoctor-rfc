require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "renders a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [keep-with-next=true, keep-with-previous=true, foo=bar]
      Lorem ipsum.
    INPUT
      <t anchor="id">Lorem ipsum.</t>
    OUTPUT
  end
end
