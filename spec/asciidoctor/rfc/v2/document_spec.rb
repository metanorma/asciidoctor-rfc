require "spec_helper"
require "byebug"
describe Asciidoctor::RFC::V2::Converter do
  it "renders the minimal document w/ default values" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      
      == Section 1
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
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all document attributes for RFC" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :name: 1111
      :abbrev: abbrev
      :doctype: rfc
      :ipr: full3978
      :consensus: false
      :obsoletes: 1, 2
      :updates: 10, 11
      :index-include: index_include_value
      :ipr-extract: ipr_extract_value
      :submission-type: IRTF
      :status: info
      :series-no: 12
      :xml-lang: en

      [[ipr_extract_value]]
      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc ipr="full3978" obsoletes="1, 2" updates="10, 11" category="info" consensus="no" submissionType="IRTF" iprExtract="ipr_extract_value" number="1111" seriesNo="12" xml:lang="en">
      <front>

         <title abbrev="abbrev">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="1970"/>


      </front><middle>
      <section anchor="ipr_extract_value" title="Section 1">

         <t>Text</t>

      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all document attributes for Internet Draft" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :name: draft-03-draft
      :abbrev: abbrev
      :doctype: internet-draft
      :ipr: full3978
      :consensus: false
      :obsoletes: 1, 2
      :updates: 10, 11
      :ipr-extract: ipr_extract_value
      :submission-type: IRTF
      :status: info
      :series-no: 12
      :xml-lang: en

      [[ipr_extract_value]]
      == Section 1
      Text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc ipr="full3978" obsoletes="1, 2" updates="10, 11" category="info" consensus="no" submissionType="IRTF" iprExtract="ipr_extract_value" docName="draft-03-draft" seriesNo="12" xml:lang="en">
      <front>

         <title abbrev="abbrev">Document title</title>

         <author fullname="Author"/>

         <date day="1" month="January" year="1970"/>


      </front><middle>
      <section anchor="ipr_extract_value" title="Section 1">

         <t>Text</t>

      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders back matter" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      == Section 1
      Text

      [appendix]
      == Appendix
      Lipsum.
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc submissionType="IETF">
      <front>
         <title>Document title</title>
         <author fullname="Author"/>
         <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
     
         <t>Text</t>
     
      </section>
      </middle><back>
      <section anchor="_appendix" title="Appendix">
     
         <t>Lipsum.</t>
     
      </section>
      </back>
      </rfc>
    OUTPUT
  end
end
