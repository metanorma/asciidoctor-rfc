require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "renders a sidebar as normal paragraphs" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      ****
      Sidebar
      
      Another sidebar
      
      * This is a list
      
      ....
      And this is ascii-art
      ....
      ****
    INPUT
        <t>Sidebar</t>
        <t>Another sidebar</t>
        <t>
        <list style="symbols">
        <t>This is a list</t>
        </list>
        </t>
        <figure>
        <artwork>
        And this is ascii-art
        </artwork>
        </figure>
    OUTPUT
  end
end
