require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "treats bcp14 macro in v2 as <strong>" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This [bcp14]#must not# stand
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>This <spanx style="strong">MUST NOT</spanx> stand</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "respects Asciidoctor inline formatting" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      _Text_ *Text* `Text` "Text" 'Text' ^Superscript^ ~Subscript~
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t><spanx style="emph">Text</spanx> <spanx style="strong">Text</spanx> <spanx style="verb">Text</spanx> "Text" 'Text' ^Superscript^ _Subscript_</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders stem as literal" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      :stem:

      == Section 1
      stem:[sqrt(4) = 2]
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>sqrt(4) = 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
