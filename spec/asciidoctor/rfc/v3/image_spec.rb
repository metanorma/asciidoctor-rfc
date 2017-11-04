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
  it "renders an image within an example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id1]]
      .Example Title
      [align=right,alt=Example]
      ====
      [[id]]
      .Image Title
      [align=center,alt=alt_text]
      image::http:://www.example/org/filename.jpg[]
      ====
    INPUT
      <figure anchor="id1">
         <name>Example Title</name>
         <artwork align="center" alt="alt_text" anchor="id" name="Image Title" src="http:://www.example/org/filename.jpg" type="binary-art"/>
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
  it "skips keyboard shortcuts" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      :experimental:
      You should click kbd:[F11] to continue.
    INPUT
      <t>You should click  to continue.</t>
    OUTPUT
  end
  it "skips menu selections" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      :experimental:
      You should click menu:View[Zoom > Reset] to continue.
    INPUT
      <t>You should click  to continue.</t>
    OUTPUT
  end
  it "skips UI buttons" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      :experimental:
      You should click btn:[OK] to continue.
    INPUT
      <t>You should click  to continue.</t>
    OUTPUT
  end
  it "skips audio" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Text

      audio::ocean_waves.mp3[options="autoplay,loop"]

      Text
    INPUT
      <t>Text</t>
      <t>Text</t>
    OUTPUT
  end
  it "skips video" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Text

      video::video_file.mp4[width=640, start=60, end=140, options=autoplay]

      Text
    INPUT
      <t>Text</t>
      <t>Text</t>
    OUTPUT
  end
end
