require "spec_helper"

xdescribe Asciidoctor::Rfc3::Converter do
  it "renders a sidebar" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      ****
      Sidebar
      ****
    INPUT
      Lipsum
    OUTPUT
  end
end
