require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders appendix when section tagged with appendix" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title>Document title</title>
       <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
       <seriesInfo name="" value=""/>
       <author fullname="Author">
       </author>
       </front><middle>
       <section anchor="_section_1" numbered="false">
       <name>Section 1</name>
       <t>text</t>
       </section>
       </middle><back>
       <section anchor="_appendix" numbered="false">
       <name>Appendix</name>
       <t>text</t>
       </section>
       </back>
       </rfc>
    OUTPUT
  end

  it "renders appendix when section follows references" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title>Document title</title>
       <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
       <seriesInfo name="" value=""/>
       <author fullname="Author">
       </author>
       </front><middle>
       <section anchor="_section_1" numbered="false">
       <name>Section 1</name>
       <t>text</t>
       </section>
       </middle><back>
       <references anchor="_biblio">
       <name>Biblio</name>
       <reference>Reference1</refcontent></reference>
       </references>
       <section anchor="_appendix" numbered="false">
       <name>Appendix</name>
       <t>text</t>
       </section>
       </back>
       </rfc>
    OUTPUT
  end

end
