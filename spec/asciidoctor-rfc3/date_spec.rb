require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  it 'renders the date' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>

      <date day="1" month="1" year="2070"/>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it 'renders the revdate' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :date: 1970-01-01T00:00:00Z
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>

      <date day="1" month="1" year="1970"/>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it 'gives precedence to revdate' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :revdate: 2070-01-01T00:00:00Z
      :date: 1970-01-01T00:00:00Z
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <seriesInfo name="Internet-Draft" stream="IETF" value=""/>
      <seriesInfo name="" value=""/>
      <author fullname="Author" initials="A">
      </author>

      <date day="1" month="1" year="2070"/>

      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
