require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      [[id]]
      [keep-with-next=true, keep-with-previous=true, foo=bar]
      Lorem ipsum.
    INPUT
      <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t anchor="id" keepWithNext="true" keepWithPrevious="true">Lorem ipsum.</t>
      </section>
    OUTPUT
  end

  it "suppresses smart apostrophes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
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
       <?rfc symrefs=""?>
       <?rfc sortrefs=""?>
       <?rfc compact="yes"?>
       <?rfc subcompact="no"?>
       <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

       </front><middle>
      <section anchor="_dantes_revenge" numbered="false">
        <name>Dante's Revenge</name>
      <t>Don't panic!</t>
      </section>
      </rfc>
    OUTPUT
  end

  it "allows smart apostrophes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Dante's Revenge
      Don't panic!
    INPUT
      <section anchor="_dantes_revenge" numbered="false">
        <name>Dante&#8217;s Revenge</name>
        <t>Don&#8217;t panic!</t>
      </section>
    OUTPUT
  end
end
