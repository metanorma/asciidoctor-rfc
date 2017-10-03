require 'spec_helper'

xdescribe Asciidoctor::Rfc3::Converter do
  it 'renders a verse' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to match <<~'OUTPUT'.chomp
      [[verse-id]]
      [verse, attribution="verse attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
       <blockquote anchor="verse-id" quotedFrom="verse attribution" cite="http://www.foo.bar">
       Text
       </blockquote>
    OUTPUT
  end
end
