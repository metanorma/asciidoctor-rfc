require 'spec_helper'

require 'asciidoctor'
require 'asciidoctor-rfc'

describe 'rfc3 converter backend' do
  it 'renders a paragraph' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to match <<~'OUTPUT'.chomp
      [[id]]
      [keepWithNext=true, keepWithPrevious=true, foo=bar]
      Lorem ipsum.
    INPUT
      <t anchor="id" keepWithNext="true" keepWithPrevious="true">Lorem ipsum.</t>
    OUTPUT
  end
end
