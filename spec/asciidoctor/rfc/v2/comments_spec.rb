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
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
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
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title abbrev="abbrev_value">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>


      </front><middle>
      <section anchor="_section1" title="Section1"><t>Text<cref>This is a note</cref></t>

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
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title abbrev="abbrev_value">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>


      </front><middle>
      <section anchor="_section1" title="Section1"><t>Text<cref>This is a note</cref></t>

      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "strips any inline formatting within Asciidoc inline admonition" do
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
      ++++
      <reference anchor='ref' target='https://www.iso.org/standard/67116.html'>
        <front>
          <title>ISO/IEC FDIS 10118-3 -- Information technology -- Security techniques -- Hash-functions -- Part 3: Dedicated hash-functions</title>
          <author>
            <organization>International Organization for Standardization</organization>
            <address>
              <postal>
                <street>BIBC II</street>
                <street>Chemin de Blandonnet 8</street>
                <street>CP 401</street>
                <city>Vernier</city>
                <region>Geneva</region>
                <code>1214</code>
                <country>Switzerland</country>
              </postal>
              <phone>+41 22 749 01 11</phone>
              <email>central@iso.org</email>
              <uri>https://www.iso.org/</uri>
            </address>
          </author>
          <date day='15' month='September' year='2017'/>
        </front>
      </reference>
      ++++
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title abbrev="abbrev_value">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>


      </front><middle>
      <section anchor="sect1" title="Section1"><t>Text<cref>Text _Text_ *Text* `Text` ~Text~ ^Text^ http://example.com/[linktext] </cref></t>

      </section>
      </middle><back>
      <references title="References">
      <reference anchor="ref" target="https://www.iso.org/standard/67116.html">
         <front>
           <title>ISO/IEC FDIS 10118-3 -- Information technology -- Security techniques -- Hash-functions -- Part 3: Dedicated hash-functions</title>
           <author>
             <organization>International Organization for Standardization</organization>
             <address>
               <postal>
                 <street>BIBC II</street>
                 <street>Chemin de Blandonnet 8</street>
                 <street>CP 401</street>
                 <city>Vernier</city>
                 <region>Geneva</region>
                 <code>1214</code>
                 <country>Switzerland</country>
               </postal>
               <phone>+41 22 749 01 11</phone>
               <email>central@iso.org</email>
               <uri>https://www.iso.org/</uri>
             </address>
           </author>
           <date day="15" month="September" year="2017"/>
         </front>
      </reference>
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

      . They are allergic to *cinnamon*.
      . More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      . Celery makes them sad.

      ....
      <tagging>
      ....
      ====
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title abbrev="abbrev_value">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>


      </front><middle>
      <section anchor="_section1" title="Section1"><t>Text<cref>While werewolves are hardy community members, keep in mind the following dietary concerns:



      They are allergic to cinnamon.



      More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.



      Celery makes them sad.
      &lt;tagging&gt;</cref></t>
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
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title abbrev="abbrev_value">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>


      </front><middle>
      <section anchor="_section1" title="Section1"><t>Text<cref anchor="id" source="GBS">Any admonition inside the body of the text is a comment.</cref></t>

      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "has a comment at the start of a section" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      NOTE: This is an initial note

      Text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc submissionType="IETF">
      <front>

         <title>Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="2000"/>

      </front><middle>
      <section anchor="_section_1" title="Section 1"><t><cref>This is an initial note</cref></t>

      <t>Text</t></section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders inline XML comments" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      A:: B [comment]#This is a comment# C D
      C [comment]#This is another comment#:: D
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>
         <list style="hanging">
           <t hangText="A"><vspace blankLines="1"/>B <!--This is a comment--> C D</t>
           <t hangText="C "><vspace blankLines="1"/>D</t>
         </list>
       </t>
      </section>
    OUTPUT
  end

  it "renders XML comment paragraphs" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [.comment]
      This is a 
      _paragraph comment_.
    INPUT
      <section anchor="_section_1" title="Section 1">
      <!--This is a _paragraph comment_.-->
      </section>
    OUTPUT
  end

  it "renders XML comment blocks" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      [.comment]
      --
      This is a 
      _paragraph comment_.

      And the comment runs over

      several paragraphs.
      --
    INPUT
      <section anchor="_section_1" title="Section 1">
      <!--This is a
       _paragraph comment_.

       And the comment runs over

       several paragraphs.
       -->
      </section>
    OUTPUT
  end


end
