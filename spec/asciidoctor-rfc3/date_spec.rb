require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  it 'renders the date' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe <john.doe@email.com>
      :revdate: 2070-01-01T00:00:00Z
    INPUT
      <date day="1" month="1" year="2070"/>
    OUTPUT
  end

  it 'renders the revdate' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe <john.doe@email.com>
      :date: 1970-01-01T00:00:00Z
    INPUT
      <date day="1" month="1" year="1970"/>
    OUTPUT
  end

  it 'gives precedence to revdate' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe <john.doe@email.com>
      :revdate: 2070-01-01T00:00:00Z
      :date: 1970-01-01T00:00:00Z
    INPUT
      <date day="1" month="1" year="2070"/>
    OUTPUT
  end
end
