require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  # TODO: this is far from exhaustive
  it 'renders the minimal document' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe <john.doe@email.com>
      :fullname: John Holmes Doe
      :lastname: Doe
      :organization: Org
      :role: Author
    INPUT
      <author fullname="John Doe" initials="J" surname="Doe" role="Author">
      <organization>Org</organization>
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
    OUTPUT
  end
end
