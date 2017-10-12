require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "ignores actual Asciidoctor comments" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author"/>
       </front><middle>
       <section anchor="_section1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       </section>
       </middle>
       </rfc>
      </rfc>
    OUTPUT
  end

  it "uses Asciidoc inline NOTE admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section1
      Text
       
      NOTE: This is a note 
       
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author"/>
       </front><middle>
       <section anchor="_section1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       <cref>
       This is a note
       </cref>
       </section>
       </middle>
       </rfc>
    OUTPUT
  end

  it "uses any Asciidoc inline admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section1
      Text
       
      WARNING: This is a note 
       
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author"/>
       </front><middle>
       <section anchor="_section1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       <cref>
       This is a note
       </cref>
       </section>
       </middle>
       </rfc>
    OUTPUT
  end

  it "uses full range of inline formatting within Asciidoc inline admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [[sect1]]
      == Section1
      Text
       
      WARNING: Text _Text_ *Text* `Text` ~Text~ ^Text^ http://example.com/[linktext] <<ref>> <<crossreference#fragment,section bare: text>>
      
      [bibliography]
      == References
      * [[[ref]]] Ref1
       
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author"/>
       </front><middle>
       <section anchor="sect1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       <cref>
       Text <em>Text</em> <strong>Text</strong> <tt>Text</tt> <sub>Text</sub> <sup>Text</sup> <eref target="http://example.com/">linktext</eref> <xref target="ref"></xref> <relref relative="fragment" section="section" displayFormat="bare" target="crossreference">text</relref>       </cref>
       </section>
       </middle><back>
       <references anchor="_references">
       <name>References</name>
       <reference anchor="ref"><refcontent>Ref1</refcontent></reference>
       </references>
       </back>
       </rfc>
    OUTPUT
  end

 it "uses Asciidoc block admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author"/>
       </front><middle>
       <section anchor="_section1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       <cref>
       While werewolves are hardy community members, keep in mind the following dietary concerns:
       They are allergic to cinnamon.
       More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
       Celery makes them sad.
       </cref>
       </section>
       </middle>
       </rfc>
    OUTPUT
  end


 it "uses all options of the Asciidoc block admonition" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section1
      Text
       
      [[id]]
      [NOTE,display=true,source=GBS]
      .Note Title
      ====
      Any admonition inside the body of the text is a comment.
      ====
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author">
       </author>
       </front><middle>
       <section anchor="_section1" numbered="false">
       <name>Section1</name>
       <t>Text</t>
       <cref anchor="id" display="true" source="GBS">
       Any admonition inside the body of the text is a comment.
       </cref>
       </section>
       </middle>
       </rfc>
       </section>
       </middle>
       </rfc>
    OUTPUT
  end




end
