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
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
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
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
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
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="1970"/>
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
