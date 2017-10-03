require 'spec_helper'

# TODO: not convinced by middle/surname and initials
describe Asciidoctor::Rfc3::Converter do
  it 'renders all options with short author syntax' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe Horton <john.doe@email.com>
    INPUT
      <author fullname="John Doe Horton" initials="J" surname="Horton">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
    OUTPUT
  end

  it 'renders all options with multiple short author syntax' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3, header_footer: true).to match <<~'OUTPUT'.chomp
      = Minimal valid document
      :docName: rfc-000000
      John Doe Horton <john.doe@email.com>; Joanna Diva Munez <joanna.munez@email.com>
    INPUT
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
    OUTPUT
  end

end
