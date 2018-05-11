require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders section with attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [remove-in-rfc=true,toc=include]
      == Section 1
      Para 1

      Para 2
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
      <section anchor="_section_1" removeInRFC="true" toc="include" numbered="false">
      <name>Section 1</name>
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders subsections" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      :sectnums:
      [toc=exclude]
      == Section 1
      Para 1

      === Subsection 1.1
      Para 1a

      :sectnums!:
      [toc=default]

      === Subsection 1.2
      Para 2

      ==== Subsection 1.2.1
      Para 3
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
      <section anchor="_section_1" toc="exclude" numbered="true">
      <name>Section 1</name>
      <t>Para 1</t>
      <section anchor="_subsection_1_1" numbered="true">
      <name>Subsection 1.1</name>
      <t>Para 1a</t>
      </section>
      <section anchor="_subsection_1_2" toc="default" numbered="false">
      <name>Subsection 1.2</name>
      <t>Para 2</t>
      <section anchor="_subsection_1_2_1" numbered="false">
      <name>Subsection 1.2.1</name>
      <t>Para 3</t>
      </section>
      </section>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores page breaks" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      <<<

      Para 2
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
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores horizontal rules" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      '''

      Para 2
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
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders floating titles" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      [discrete]
      == Section 2
      Para 2
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
      <t>Para 1</t>
      <t><strong>Section 2</strong></t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "supresses natural cross-references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[hash_whirlpool]]
      === WHIRLPOOL

      The WHIRLPOOL hash function is defined in <<WHIRLPOOL>>.

      This section should actually be referenced as <<hash_whirlpool>>.
      ...

      [bibliography]
      == Informative References
      ++++
      <reference anchor='WHIRLPOOL' target='http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html'>
      ...
      ++++
    INPUT
    <?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="rfc2629.xslt"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">
<?rfc strict="yes"?>
<?rfc compact="yes"?>
<?rfc subcompact="no"?>
<?rfc toc="yes"?>
<?rfc tocdepth="4"?>
<?rfc symrefs="yes"?>
<?rfc sortrefs="yes"?>
       <rfc xmlns:xi="http://www.w3.org/2001/XInclude" submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
       <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

       </front><middle>
       <section anchor="hash_whirlpool" numbered="false"><name>WHIRLPOOL</name><t>The WHIRLPOOL hash function is defined in <xref target="WHIRLPOOL"/>.</t>
       <t>This section should actually be referenced as <xref target="hash_whirlpool"/>.
       &#8230;&#8203;</t></section>
       </middle><back>
       <references anchor="_informative_references">
         <name>Informative References</name>
         <reference anchor="WHIRLPOOL" target="http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html">
       ...</reference>
       </references>
       </back>
       </rfc>
    OUTPUT
  end
end
