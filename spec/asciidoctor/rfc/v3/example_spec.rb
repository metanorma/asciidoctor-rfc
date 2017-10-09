require "spec_helper"

describe Asciidoctor::RFC::V3::Converter do
  it "renders a minimal example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      ====
      Example
      ====
    INPUT
       <figure>
       <t>Example</t>
       </figure>
    OUTPUT
  end

  it "renders a maximal example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Figure 1
      ====

      [[id2]]
      .figure1.txt
      ....
      Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
      ....


      ====
    INPUT
       <figure anchor="id">
       <name>Figure 1</name>
       <artwork anchor="id2" name="figure1.txt" type="ascii-art">
       Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
       </artwork>
       </figure>
    OUTPUT
  end




end
