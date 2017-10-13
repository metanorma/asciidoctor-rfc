require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [keep-with-next=true, keep-with-previous=true, foo=bar]
      Lorem ipsum.
    INPUT
      <t anchor="id" keepWithNext="true" keepWithPrevious="true">Lorem ipsum.</t>
    OUTPUT
  end
end
