require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders an image with block attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Title
      [align=center,alt=alt_text]
      image::http:://www.example/org/filename.jpg[]
    INPUT
       <figure>
       <artwork anchor="id" name="Title" align="center" alt="alt_text" type="binary-art" src="http:://www.example/org/filename.jpg"/>
       </figure>
    OUTPUT
  end

  it "renders an image with macro attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Title
      image::http:://www.example/org/filename.jpg[alt_text,300,200]
    INPUT
       <figure>
       <artwork anchor="id" name="Title" alt="alt_text" type="binary-art" src="http:://www.example/org/filename.jpg" width="300" height="200"/>
       </figure>
    OUTPUT
  end

  it "skips inline images" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      You should click image:play.jpg[Sunset] to continue.
    INPUT
       <t>You should click  to continue.</t>
    OUTPUT
  end



end
