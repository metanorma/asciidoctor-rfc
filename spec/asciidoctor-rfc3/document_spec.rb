require 'spec_helper'

xdescribe Asciidoctor::Rfc3::Converter do
  it 'renders a document' do
    expect(Asciidoctor.convert <<~'INPUT', backend: :rfc3).to match <<~'OUTPUT'.chomp
      =Title
      Author
      :ipr
      :obsoletes
      :updates
      :submissionType
      :indexInclude
      :iprExtract
      :sortRefs
      :symRefs
      :tocInclude

      ABSTRACT

      NOTEs

      ==first title
      CONTENT

      [bibliography] # start of back matter
      == Bibliography

      [appendix] # start of back matter if not already started
      == Appendix
    INPUT
    OUTPUT
  end
end
