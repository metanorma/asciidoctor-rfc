require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders a maximal example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      .Figure 1
      [align=left,alt=Alt Text,suppress-title=true]
      ====
      [[id2]]
      .figure1.txt
      ....
      Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
      ....
      ====
    INPUT
      <figure anchor="id" align="left" alt="Alt Text" title="Figure 1" suppress-title="true">
      <artwork anchor="id2" name="figure1.txt">
      Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
      </artwork>
      </figure>
    OUTPUT
  end

  it "renders preambles and postambles in example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      ====
      Preamble text
      .figure1.txt
      ....
      Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
      ....
      Postamble text
      ====
    INPUT
      <figure>
      <preamble>
      Preamble text
      </preamble>
      <artwork name="figure1.txt">
      Figures are only permitted to contain listings (sourcecode), images (artwork), or literal (artwork)
      </artwork>
      <postamble>
      Postamble text
      </postamble>
      </figure>
    OUTPUT
  end
end
