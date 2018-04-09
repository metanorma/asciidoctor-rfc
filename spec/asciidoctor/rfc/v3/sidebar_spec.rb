require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a sidebar" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
      <aside anchor="id"><t>Sidebar</t>
      <t>Another sidebar</t>
      <ul>
      <li>This is a list</li>
      </ul>
      <figure>
        <artwork type="ascii-art"><![CDATA[
      And this is ascii-art
      ]]></artwork>
      </figure></aside>
    OUTPUT
  end
end
