require "spec_helper"

describe Asciidoctor::Rfc3::Converter do
  it "renders no abstract if preamble has no content" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docName:

      = Lorem

      Ipsum.
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>

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

      = Lorem

      Ipsum.
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>

      <abstract>
      <t>Preamble content.</t>
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
end
