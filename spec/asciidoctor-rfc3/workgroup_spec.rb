require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  it 'renders workgroups' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe <john.doe@email.com>
      :workgroup: first_workgroup, second_workgroup
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
               version="3" submisionType="IETF">
      <front>
      <title>Minimal valid document</title>
      <seriesInfo name="RFC" stream="IETF" value="000000"/>
      <seriesInfo name="" value="000000"/>
      <author fullname="John Doe" initials="J" surname="Doe">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
      <workgroup>first_workgroup</workgroup>
      <workgroup>second_workgroup</workgroup>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
