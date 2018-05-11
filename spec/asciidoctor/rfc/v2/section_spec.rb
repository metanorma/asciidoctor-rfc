require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders section with attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[id]]
      == Section 1
      Para 1

      Para 2
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="id" title="Section 1">
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "strips formatting in section titles" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[id]]
      == `Section` 1
      Para 1

      Para 2
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="id" title="Section 1">
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end


  it "renders HTML entities and Non-ASCII characters and in section title attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[id]]
      == Section&nbsp;(Секция) 1
      Para 1

      Para 2
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="id" title="Section&#160;(&#1057;&#1077;&#1082;&#1094;&#1080;&#1103;) 1">
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders subsections" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      === Subsection 1.1
      Para 1a

      === Subsection 1.2
      Para 2

      ==== Subsection 1.2.1
      Para 3
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>Para 1</t>
      <section anchor="_subsection_1_1" title="Subsection 1.1">
      <t>Para 1a</t>
      </section>
      <section anchor="_subsection_1_2" title="Subsection 1.2">
      <t>Para 2</t>
      <section anchor="_subsection_1_2_1" title="Subsection 1.2.1">
      <t>Para 3</t>
      </section>
      </section>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores sectnums" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      :sectnums:
      == Section 1
      Para 1

      === Subsection 1.1
      Para 1a

      :sectnums!:
      === Subsection 1.2
      Para 2

      ==== Subsection 1.2.1
      Para 3
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>Para 1</t>
      <section anchor="_subsection_1_1" title="Subsection 1.1">
      <t>Para 1a</t>
      </section>
      <section anchor="_subsection_1_2" title="Subsection 1.2">
      <t>Para 2</t>
      <section anchor="_subsection_1_2_1" title="Subsection 1.2.1">
      <t>Para 3</t>
      </section>
      </section>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores page breaks" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores horizontal rules" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders floating titles" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>Para 1</t>
      <t><spanx style="strong">Section 2</spanx></t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "supresses natural cross-references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
           <rfc submissionType="IETF">
       <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="2000"/>

       </front><middle>
       <section anchor="hash_whirlpool" title="WHIRLPOOL"><t>The WHIRLPOOL hash function is defined in <xref target="WHIRLPOOL"/>.</t>
       <t>This section should actually be referenced as <xref target="hash_whirlpool"/>.
       &#8230;&#8203;</t></section>
       </middle><back>
       <references title="Informative References">
         <reference anchor="WHIRLPOOL" target="http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html">
       ...</reference>
       </references>
       </back>
       </rfc>
    OUTPUT
  end
end
