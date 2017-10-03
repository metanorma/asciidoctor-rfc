require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  it 'renders links' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      John Doe <john.doe@email.com>
      :docName: rfc-000000
      :link: http://foo.bar,http://baz.qux baz_qux_rel
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
               version="3" submisionType="IETF">
      <link href="http://foo.bar"/>
      <link href="http://baz.qux" rel="baz_qux_rel"/>
      <front>
      <title>Minimal valid document</title>
      <seriesInfo name="RFC" stream="IETF" value="000000"/>
      <seriesInfo name="" value="000000"/>
      <author fullname="John Doe" initials="J" surname="Doe">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end

