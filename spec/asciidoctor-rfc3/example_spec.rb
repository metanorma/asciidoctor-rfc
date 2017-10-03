require 'spec_helper'

xdescribe Asciidoctor::Rfc3::Converter do
  it 'renders a paragraph' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to match <<~'OUTPUT'.chomp
      [[image-id]]
      .Image title
      [link=url, align=left, alt=alt_text]
      image::image.png[]
    INPUT
    OUTPUT
  end
end
