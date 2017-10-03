require 'spec_helper'

xdescribe Asciidoctor::Rfc3::Converter do
  it 'renders an image' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to match <<~'OUTPUT'.chomp
      .Example title
      ====
      Example content.
      ====
    INPUT
    OUTPUT
  end
end
