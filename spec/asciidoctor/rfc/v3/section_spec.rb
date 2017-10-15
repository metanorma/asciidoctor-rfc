require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders section with attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      [remove-in-rfc=true,toc=include]
      == Section 1
      Para 1

      Para 2
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      <section anchor="_section_1" removeInRFC="true" toc="include" numbered="false">
      <name>Section 1</name>
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders subsections" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      :sectnums:
      [toc=exclude]
      == Section 1
      Para 1

      ==== Subsection 1.1
      Para 1a

      :sectnums!:
      [toc=default]

      === Subsection 1.2
      Para 2

      ==== Subsection 1.2.1
      Para 3
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      <section anchor="_section_1" toc="exclude" numbered="true">
      <name>Section 1</name>
      <t>Para 1</t>
      <section anchor="_subsection_1_1" numbered="true">
      <name>Subsection 1.1</name>
      <t>Para 1a</t>
      </section>
      <section anchor="_subsection_1_2" toc="default" numbered="false">
      <name>Subsection 1.2</name>
      <t>Para 2</t>
      <section anchor="_subsection_1_2_1" numbered="false">
      <name>Subsection 1.2.1</name>
      <t>Para 3</t>
      </section>
      </section>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores page breaks" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      <<<

      Para 2
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores horizontal rules" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      '''

      Para 2
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Para 1</t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders floating titles" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Para 1

      [discrete]
      == Section 2
      Para 2
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Para 1</t>
      <t><strong>Section 2</strong></t>
      <t>Para 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
