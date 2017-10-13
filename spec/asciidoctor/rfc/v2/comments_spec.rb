require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "ignores actual Asciidoctor comments" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      == Section1
      Text
      //Ignorable comment
      ////
        Multiblock ignorable comment
      ////
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
                submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section1" title="Section1">
      <t>Text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "uses Asciidoc inline NOTE admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      == Section1
      Text
      NOTE: This is a note
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section1" title="Section1">
      <t>Text</t>
      <t>
      <cref>
      This is a note
      </cref>
      </t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "uses any Asciidoc inline admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      == Section1
      Text
      WARNING: This is a note
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section1" title="Section1">
      <t>Text</t>
      <t>
      <cref>
      This is a note
      </cref>
      </t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "uses full range of inline formatting within Asciidoc inline admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      [[sect1]]
      == Section1
      Text
      WARNING: Text _Text_ *Text* `Text` ~Text~ ^Text^ http://example.com/[linktext] <<ref>>
      [bibliography]
      == References
      * [[[ref]]] Ref1
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="sect1" title="Section1">
      <t>Text</t>
      <t>
      <cref>
      Text <spanx style="emph">Text</spanx> <spanx style="strong">Text</spanx> <spanx style="verb">Text</spanx> _Text_ ^Text^ <eref target="http://example.com/">linktext</eref> <xref target="ref"></xref>
      </cref>
      </t>
      </section>
      </middle><back>
      <references title="References">
      </references>
      </back>
      </rfc>
    OUTPUT
  end

  it "uses Asciidoc block admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      == Section1
      Text
      [IMPORTANT]
      .Feeding the Werewolves
      ====
      While werewolves are hardy community members, keep in mind the following dietary concerns:
      . They are allergic to cinnamon.
      . More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      . Celery makes them sad.
      ====
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section1" title="Section1">
      <t>Text</t>
      <t>
      <cref>
      While werewolves are hardy community members, keep in mind the following dietary concerns:
      They are allergic to cinnamon.
      More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      Celery makes them sad.
      </cref>
      </t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "uses all options of the Asciidoc block admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      == Section1
      Text
      [[id]]
      [NOTE,source=GBS]
      .Note Title
      ====
      Any admonition inside the body of the text is a comment.
      ====
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section1" title="Section1">
      <t>Text</t>
      <t>
      <cref anchor="id" source="GBS">
      Any admonition inside the body of the text is a comment.
      </cref>
      </t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
