require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      [[id]]
      [keep-with-next=true, keep-with-previous=true, foo=bar]
      Lorem ipsum.
    INPUT
      <section anchor="_section_1" title="Section 1">
      <t anchor="id">Lorem ipsum.</t>
      </section>
    OUTPUT
  end

  it "suppresses smart apostrophes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :smart-quotes: false
      Author

      == Dante's Revenge
      Don't panic!
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">
      <?rfc strict="yes"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <rfc submissionType="IETF">
      <front>
        <title abbrev="abbrev_value">Document title</title>
        <author fullname="Author"/>
        <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_dante_s_revenge" title="Dante's Revenge">
      <t>Don't panic!</t>
      </section>
      </rfc>
    OUTPUT
  end

  it "allows smart apostrophes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Dante's Revenge
      Don't panic!
    INPUT
      <section anchor="_dante_s_revenge" title="Dante&#8217;s Revenge">
      <t>Don&#8217;t panic!</t>
      </section>
    OUTPUT
  end
end
