require "spec_helper"
require "byebug"
describe Asciidoctor::RFC::V3::Converter do
  it "renders the minimal document w/ default values" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders all document attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :abbrev: abbrev
      :ipr: ipr_value
      :consensus: false
      :obsoletes: 1, 2
      :updates: 10, 11
      :index-include: true
      :ipr-extract: ipr_extract_value
      :sort-refs: true
      :sym-refs: false
      :toc-include: false
      :toc-depth: 2
      :submission-type: IRTF

      [[ipr_extract_value]]
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc ipr="ipr_value" obsoletes="1, 2" updates="10, 11" prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IRTF" indexInclude="true" iprExtract="ipr_extract_value" sortRefs="true" symRefs="false" tocInclude="false" tocDepth="2">
      <front>
      <title abbrev="abbrev">Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="ipr_extract_value" numbered="false">
      <name>Section 1</name>
      <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders back matter" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      text

      [appendix]
      == Appendix
      Lipsum.
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
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>text</t>
      </section>
      </middle><back>
      <section anchor="_appendix" numbered="false">
      <name>Appendix</name>
      <t>Lipsum.</t>
      </section>
      </back>
      </rfc>
    OUTPUT
  end
end
