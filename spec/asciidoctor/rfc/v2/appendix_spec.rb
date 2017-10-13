require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders appendix when section tagged with appendix" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      == Section 1
      text
      [appendix]
      == Appendix
      text
   INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
      submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>text</t>
      </section>
      </middle><back>
      <section anchor="_appendix" title="Appendix">
      <t>text</t>
      </section>
      </back>
      </rfc>
    OUTPUT
  end

  it "renders appendix when section follows references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
        Author
      == Section 1
      text
      [bibliography]
      == Biblio
      * Reference1
      == Appendix
      text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
      submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>text</t>
      </section>
      </middle><back>
      <references title="Biblio">
      </references>
      <section anchor="_appendix" title="Appendix">
      <t>text</t>
      </section>
      </back>
      </rfc>
    OUTPUT
  end
end
