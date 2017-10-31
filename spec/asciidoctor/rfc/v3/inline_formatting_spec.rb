require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "treats bcp14 macro in v3 as <bcp14>" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This [bcp14]#must not# stand
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
      <t>This <bcp14>MUST NOT</bcp14> stand</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "treats boldfaced capital BCP14 in v3 as <bcp14> by default" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This *MUST NOT* stand
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
      <t>This <bcp14>MUST NOT</bcp14> stand</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "treats boldfaced capital BCP14 in v3 as normal strong text, if flag :no-rfc-bold-bcp14:." do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :no-rfc-bold-bcp14:
      :docName:
      Author

      == Section 1
      This *MUST NOT* stand
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
      <t>This <strong>MUST NOT</strong> stand</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "respects Asciidoctor inline formatting" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      _Text_ *Text* `Text` "`Text`" '`Text`' ^Superscript^ ~Subscript~
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
      <t><em>Text</em> <strong>Text</strong> <tt>Text</tt> &#8220;Text&#8221; &#8216;Text&#8217; <sup>Superscript</sup> <sub>Subscript</sub></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "allows suppression of smart quotes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      :smart-quotes: false
      Author

      == Section 1
      "`Text`" '`Text`'
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
      <t>"Text" 'Text'</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders stem as literal" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      :stem:

      == Section 1
      stem:[sqrt(4) = 2]
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
      <t>sqrt(4) = 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "render line break within table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      .Table Title
      [cols="2"]
      |===
      |head
      |head +
      head

      h|header cell | *body* cell +
      cell
      |===
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
         <title>Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
        <name>Section 1</name>
        <table>
        <name>Table Title</name>
        <tbody>
          <tr>
            <td align="left">head</td>
            <td align="left">head<br/>
      head</td>
          </tr>
          <tr>
            <th align="left">header cell</th>
            <td align="left"><strong>body</strong> cell<br/>
      cell</td>
          </tr>
        </tbody>
      </table>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "ignore line break outside of table" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      :stem:

      == Section 1
      Hello +
      This is a line break
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
         <name>Section 1</name>
         <t>Hello
       This is a line break</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "deals with non-Ascii characters" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Hello René! Hello Владимир!

    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
         <name>Section 1</name>
         <t>Hello Ren&#233;! Hello &#1042;&#1083;&#1072;&#1076;&#1080;&#1084;&#1080;&#1088;!</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "deals with HTML entities" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      :stem:

      == Section 1
      Hello &lt;&nbsp;(&amp;lt;)

      == Section 2
      Hello &lt;&nbsp;(&amp;lt;)
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF" prepTime="2000-01-01T05:00:00Z" version="3">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" numbered="false">
         <name>Section 1</name>
         <t>Hello &lt;&#160;(&amp;lt;)</t>
      </section>
      <section anchor="_section_2" numbered="false">
         <name>Section 2</name>
         <t>Hello &lt;&#160;(&amp;lt;)</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
