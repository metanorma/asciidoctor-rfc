require 'spec_helper'

describe Asciidoctor::Rfc3::Converter do
  it 'renders a quote' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to be_equivalent_to <<~'OUTPUT'
      [[quote-id]]
      [quote, attribution="quote attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
       <blockquote anchor="quote-id" quotedFrom="quote attribution" cite="http://www.foo.bar">
       Text
       </blockquote>
    OUTPUT
  end
end
