require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "renders index" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      This ((indexterm)) 
      is visible in the text,
      this one is not (((indexterm, index-subterm))). 
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author">
       </author>
       </front><middle>
       <t>This indexterm<iref item="indexterm"/>
       is visible in the text,
       this one is not <iref item="indexterm" subitem="index-subterm"/>.</t>
       </middle>
       </rfc>
    OUTPUT
  end

  it "does not render tertiary index terms" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      This ((indexterm)) 
      is visible in the text,
      this one with a tertiary term is not (((indexterm, index-subterm, index-subsubterm))). 
    INPUT
       <?xml version="1.0" encoding="UTF-8"?>
       <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
       <front>
       <title abbrev="abbrev_value">Document title</title>
       <author fullname="Author">
       </author>
       </front><middle>
       <t>This indexterm<iref item="indexterm"/>
       is visible in the text,
       this one with a tertiary term is not <iref item="indexterm" subitem="index-subterm"/>.</t>
       </middle>
       </rfc>
    OUTPUT
  end


end
