require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders an image" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Click image:icons/play.png[Play, title="Play"] to get the party started.
      Click image:icons/pause.png[title="Pause"] when you need a break.
      image:sunset.jpg[Sunset,150,150,role="right"] What a beautiful sunset!
    INPUT
      foobar
    OUTPUT
  end
end
