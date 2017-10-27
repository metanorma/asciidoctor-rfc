require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders workgroups" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :workgroup: first_workgroup, second_workgroup
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      <workgroup>first_workgroup</workgroup><workgroup>second_workgroup</workgroup>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "deals with entities in workgroups" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :workgroup: first_workgroup & second_workgroup
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      <workgroup>first_workgroup &amp; second_workgroup</workgroup>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
