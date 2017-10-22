require "spec_helper"
require "date"
describe Asciidoctor::RFC::V2::Converter do
  it "renders the date" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2070"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders the revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :date: 1970-01-01T00:00:00Z
      
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

  it "gives precedence to revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z
      :date: 1970-01-01T00:00:00Z
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2070"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  
    it "permits partial revdate" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 1972
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date year="1972"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end



  # it "supplies today's date if no date given" do
  #   expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
  #     = Document title
  #     :docName:
  #     Author
  #   INPUT
  #       <?xml version="1.0" encoding="UTF-8"?>
  #       <rfc
  #                submissionType="IETF">
  #       <front>
  #       <title>Document title</title>
  #       <author fullname="Author"/>
  #     <date day="#{DateTime.now.day}" month="#{Date::MONTHNAMES[DateTime.now.month]}" year="#{DateTime.now.year}"/>
  #     </front><middle>
  #     </middle>
  #     </rfc>
  #   OUTPUT
  # end
end
