require "spec_helper"

xdescribe Asciidoctor::RFC::V3::Converter do
  it "renders a listing" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      [align=left, alt=alt_text]
      ....
        Literal contents.
      ....
    INPUT
      <figure>
      <artwork anchor="literal-id" align="left" alt="alt_text" type="ascii-art">
        Literal contents.
      </artwork>
      </figure>
    OUTPUT
  end
  
  # No callouts
  
  
end
