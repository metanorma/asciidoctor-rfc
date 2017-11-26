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

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" status="informational" stream="IRTF" value="internet-draft-this-is-an-internet-draft-00"/>
      <seriesInfo name="" status="bcp" value="internet-draft-this-is-an-internet-draft-00"/>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
       <section anchor="_section_1" numbered="false">

         <name>Section 1</name>

         <t>Text</t>

       </section>
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

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="fyi" value="1111"/>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
       <section anchor="_section_1" numbered="false">

         <name>Section 1</name>

         <t>Text</t>

       </section>
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

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="fyi" value="1111"/>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
       <section anchor="_section_1" numbered="false">

         <name>Section 1</name>

         <t>Text</t>

       </section>
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

      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc prepTime="2000-01-01T05:00:00Z"
                version="3" submissionType="IRTF">
      <front>
      <title>Document title</title>
      <seriesInfo name="RFC" status="full-standard" stream="IRTF" value="1111"/>
      <seriesInfo name="" status="historic" value="1111"/>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      </front><middle>
       <section anchor="_section_1" numbered="false">

         <name>Section 1</name>

         <t>Text</t>

       </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "sets seriesInfo attributes for RFC with illegal intended status" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :doctype: internet-draft
      :name: draft-xxx
      :status: full-standard
      :intended-series: illegal
      :submission-type: IRTF

      == Section 1
      Text
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
       <rfc submissionType="IRTF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title>Document title</title>
         <seriesInfo name="Internet-Draft" status="full-standard" stream="IRTF" value="draft-xxx"/>
         <seriesInfo name="" status="illegal" value="draft-xxx"/>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

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
