require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "sets seriesInfo attributes for Internet Draft" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft
      :name: internet-draft-this-is-an-internet-draft-00
      :status: informational
      :intended-series: bcp
      :submission-type: IRTF
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" status="informational" stream="IRTF" value="internet-draft-this-is-an-internet-draft-00"/>
      <seriesInfo name="" status="bcp" value="internet-draft-this-is-an-internet-draft-00"/>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
  it "sets seriesInfo attributes for RFC, with FYI status" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: rfc
      :name: 1111
      :status: full-standard
      :intended-series: fyi 1111
      :submission-type: IRTF
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="fyi" value="1111"/>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
  it "treats the rfc- prefix on :name: as optional" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: rfc
      :name: rfc-1111
      :status: full-standard
      :intended-series: fyi 1111
      :submission-type: IRTF
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="fyi" value="1111"/>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
  it "sets seriesInfo attributes for RFC with historic status" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: rfc
      :name: rfc-1111
      :status: full-standard
      :intended-series: historic
      :submission-type: IRTF
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="historic" value="1111"/>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
