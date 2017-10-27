require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders the date" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2070"/>
      </front><middle>
        <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t>Text</t>
        </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders the revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :date: 1970-01-01T00:00:00Z

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
        <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t>Text</t>
        </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "gives precedence to revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z
      :date: 1970-01-01T00:00:00Z

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2070"/>
      </front><middle>
        <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t>Text</t>
        </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "permits year-only revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 1972

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date year="1972"/>
      </front><middle>
        <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t>Text</t>
        </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "permits year-month revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 1972-06

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date year="1972" month="June"/>
      </front><middle>
        <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <t>Text</t>
        </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
