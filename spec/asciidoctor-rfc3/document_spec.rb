require "spec_helper"
require "byebug"

describe Asciidoctor::Rfc3::Converter do
  it "renders the minimal document w/ default values" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all document attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :ipr: ipr_value
      :obsoletes: obsoletes_value
      :updates: updates_value
      :index-include: index_include_value
      :ipr-extract: ipr_extract_value
      :sort-refs: sort_refs_value
      :sym-refs: sym_refs_value
      :toc-include: toc_include_value
      :submission-type: submission_type_value
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc ipr="ipr_value"
           obsoletes="obsoletes_value"
           updates="updates_value"
           preptime="1970-01-01T00:00:00Z"
           version="3"
           submissionType="submission_type_value"
           indexInclude="index_include_value"
           iprExtract="ipr_extract_value"
           sortRefs="sort_refs_value"
           symRefs="sym_refs_value"
           tocInclude="toc_include_value" >
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders back matter" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      [appendix]
      == Appendix

      Lipsum.
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>
      </front><middle>
      </middle><back>
      <section anchor="_appendix" numbered="false">
      <name>Appendix</name>
      <t>Lipsum.</t>
      </section>
      </back>
      </rfc>
    OUTPUT
  end
end
