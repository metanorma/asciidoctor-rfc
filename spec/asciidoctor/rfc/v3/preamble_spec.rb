require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders no abstract if preamble has no content" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders preamble contents as abstract" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      Preamble content.

      More Preamble content.

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <abstract>
      <t>Preamble content.</t>
      <t>More Preamble content.</t>
      </abstract>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders admonitions in preamble as notes, following an abstract" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:
      
      Abstract

      [NOTE]
      .Title of Note
      ====
      This is another note.
      ====

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <abstract><t>Abstract</t></abstract>
      <note>
      <name>Title of Note</name>
      <t>This is another note.</t>
      </note>
      </front><middle>
      <section anchor="_lorem" numbered="false">
         <name>Lorem</name>
         <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders unordered lists in preamble as abstract" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      * Preamble 1
      * Preamble 2

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <abstract>
      <ul>
         <li>Preamble 1</li>
         <li>Preamble 2</li>
      </ul>
      </abstract>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders ordered lists in preamble as abstract" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      . Preamble 1
      . Preamble 2

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <abstract>
      <ol type="1">
         <li>Preamble 1</li>
         <li>Preamble 2</li>
      </ol>
      </abstract>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders definition lists in preamble as abstract" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      Preamble 1:: Preamble 2

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <abstract>
        <dl>
          <dt>Preamble 1</dt>
          <dd>Preamble 2</dd>
        </dl>
      </abstract>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders admonitions in preamble as notes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      NOTE: This is a note.

      [NOTE,remove-in-rfc=true]
      .Title of Note
      ====
      This is another note.
      ====

      == Lorem
      Ipsum.
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <note>
      <t>
      This is a note.
      </t>
      </note>
      <note removeInRFC="true">
      <name>Title of Note</name>
      <t>This is another note.</t>
      </note>
      </front><middle>
      <section anchor="_lorem" numbered="false">
      <name>Lorem</name>
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
