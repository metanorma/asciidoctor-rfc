require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a quote" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [quote, attribution="quote attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
      <blockquote anchor="verse-id" quotedFrom="quote attribution" cite="http://www.foo.bar">
      Text
      </blockquote>
    OUTPUT
  end

  it "renders a multi-paragraph quote" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [quote, attribution="quote attribution", citetitle="http://www.foo.bar"]
      ____
      Dennis: Come and see the violence inherent in the system. Help! Help! I'm being repressed!

      King Arthur: Bloody peasant!

      Dennis: Oh, what a giveaway! Did you hear that? Did you hear that, eh? That's what I'm on about! Did you see him repressing me? You saw him, Didn't you?
      ____
    INPUT
      <blockquote anchor="verse-id" quotedFrom="quote attribution" cite="http://www.foo.bar">
      <t>Dennis: Come and see the violence inherent in the system. Help! Help! I&#8217;m being repressed!</t>
      <t>King Arthur: Bloody peasant!</t>
      <t>Dennis: Oh, what a giveaway! Did you hear that? Did you hear that, eh? That&#8217;s what I&#8217;m on about! Did you see him repressing me? You saw him, Didn&#8217;t you?</t>
      </blockquote>
    OUTPUT
  end

  it "renders a quoted paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      "I hold it that a little rebellion now and then is a good thing,
      and as necessary in the political world as storms in the physical."
      -- Thomas Jefferson, Papers of Thomas Jefferson: Volume 11
    INPUT
      <blockquote anchor="verse-id" quotedFrom="Thomas Jefferson" cite="Papers of Thomas Jefferson: Volume 11">
      I hold it that a little rebellion now and then is a good thing,
      and as necessary in the political world as storms in the physical.
      </blockquote>
    OUTPUT
  end

  it "renders a blockquote with internal markup" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      > I've got Markdown in my AsciiDoc!
      >
      > * Blockquotes
      > * Headings
      > * Fenced code blocks
      >
      > ....
      > Wha?
      > ....
      >
      > Yep. AsciiDoc and Markdown share a lot of common syntax already.
    INPUT
      <blockquote>
      <t>I&#8217;ve got Markdown in my AsciiDoc!</t>
      <ul>
      <li>Blockquotes</li>
      <li>Headings</li>
      <li>Fenced code blocks</li>
      </ul>
      <figure>
      <artwork type="ascii-art">
      Wha?
      </artwork>
      </figure>
      <t>Yep. AsciiDoc and Markdown share a lot of common syntax already.</t>
      </blockquote>
    OUTPUT
  end

  it "renders a verse" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [verse, Carl Sandburg, two lines from the poem Fog]
      The *fog* comes
      on little cat feet.
    INPUT
      <blockquote anchor="verse-id" quotedFrom="Carl Sandburg">The <strong>fog</strong> comes<br/>
      on little cat feet.</blockquote>
    OUTPUT
  end
end
