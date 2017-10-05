require "spec_helper"

# TODO: not convinced by middle/surname and initials
describe Asciidoctor::RFC::V3::Converter do
  it "renders all options with short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>

      <author fullname="John Doe Horton" initials="J" surname="Horton">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with multiple short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>; Joanna Diva Munez <joanna.munez@email.com>
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>

      <author fullname="John Doe Horton" initials="J" surname="Horton">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
      <author fullname="Joanna Diva Munez" initials="J" surname="Munez">
      <address>
      <email>joanna.munez@email.com</email>
      </address>
      </author>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
