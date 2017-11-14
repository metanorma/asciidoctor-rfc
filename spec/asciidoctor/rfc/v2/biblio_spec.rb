require "spec_helper"

describe Asciidoctor::RFC::V2::Converter do
  it "processes v2 sample biblio file" do
    system("bin/asciidoctor-rfc2 -r asciidoctor-bibliography spec/examples/refs-v2.adoc -o spec/examples/refs-v2.new.xml")
    expect(File.read("spec/examples/refs-v2.new.xml")).to be_equivalent_to File.read("spec/examples/refs-v2.xml")
  end
end
