require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders index" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This ((indexterm))
      is visible in the text,
      this one is not (((indexterm, index-subterm))).
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>This indexterm<iref item="indexterm"/>
      is visible in the text,
      this one is not <iref item="indexterm" subitem="index-subterm"/>.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "does not render tertiary index terms" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This ((indexterm))
      is visible in the text,
      this one with a tertiary term is not (((indexterm, index-subterm, index-subsubterm))).
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>This indexterm<iref item="indexterm"/>
      is visible in the text,
      this one with a tertiary term is not <iref item="indexterm" subitem="index-subterm"/>.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
