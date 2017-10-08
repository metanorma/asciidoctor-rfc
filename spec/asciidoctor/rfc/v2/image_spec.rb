require "spec_helper"

xdescribe Asciidoctor::RFC::V2::Converter do
  it "renders an image" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Title
      [link=xxx,align=left|center|righti,alt=alt_text]
      image::filename[]
    INPUT
      foobar
    OUTPUT
  end
end
