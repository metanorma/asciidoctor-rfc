require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
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
