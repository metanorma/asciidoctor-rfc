require "spec_helper"

xdescribe Asciidoctor::Rfc3::Converter do
  it "renders an image" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Click image:icons/play.png[Play, title="Play"] to get the party started.
      Click image:icons/pause.png[title="Pause"] when you need a break.
      image:sunset.jpg[Sunset,150,150,role="right"] What a beautiful sunset!
    INPUT
    OUTPUT
  end
end
