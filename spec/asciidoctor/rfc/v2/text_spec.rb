require "spec_helper"

def text_compare(old_xml, new_xml)
  File.write("#{old_xml}.1", norm(File.read(old_xml)))
  File.write("#{new_xml}.1", norm(File.read(new_xml)))
  system("xml2rfc #{old_xml}.1 -o #{old_xml}.txt")
  system("xml2rfc #{new_xml}.1 -o #{new_xml}.txt")
end

def norm(text)
  text.gsub(%r{<spanx style="strong">(MUST|MUST NOT|REQUIRED|SHALL|SHALL NOT|SHOULD|SHOULD NOT|RECOMMENDED|MAY|OPTIONAL)</spanx>}, "\\1")
end

describe Asciidoctor::RFC::V2::Converter do
  it "processes Davies template with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/davies-template-bare-06.adoc")
    text_compare("spec/examples/davies-template-bare-06.xml.orig", "spec/examples/davies-template-bare-06.xml")
    expect(norm(File.read("spec/examples/davies-template-bare-06.xml.orig.txt"))).to be_equivalent_to norm(File.read("spec/examples/davies-template-bare-06.xml.txt"))
  end
  it "processes MIB template with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/mib-doc-template-xml-06.adoc")
    text_compare("spec/examples/mib-doc-template-xml-06.xml.orig", "spec/examples/mib-doc-template-xml-06.xml")
    expect(norm(File.read("spec/examples/mib-doc-template-xml-06.xml.orig.txt"))).to be_equivalent_to norm(File.read("spec/examples/mib-doc-template-xml-06.xml.txt"))
  end
  it "processes rfc1149 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc1149.md.adoc")
    text_compare("spec/examples/rfc1149.md.2.xml", "spec/examples/rfc1149.md.xml")
    expect(norm(File.read("spec/examples/rfc1149.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc1149.md.xml.txt"))
  end
  it "processes rfc2100 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc2100.md.adoc")
    text_compare("spec/examples/rfc2100.md.2.xml", "spec/examples/rfc2100.md.xml")
    expect(norm(File.read("spec/examples/rfc2100.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc2100.md.xml.txt"))
  end
  it "processes rfc3514 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc3514.md.adoc")
    text_compare("spec/examples/rfc3514.md.2.xml", "spec/examples/rfc3514.md.xml")
    expect(norm(File.read("spec/examples/rfc3514.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc3514.md.xml.txt"))
  end
  it "processes rfc5841 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc5841.md.adoc")
    text_compare("spec/examples/rfc5841.md.2.xml", "spec/examples/rfc5841.md.xml")
    expect(norm(File.read("spec/examples/rfc5841.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc5841.md.xml.txt"))
  end
  it "processes rfc748 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc748.md.adoc")
    text_compare("spec/examples/rfc748.md.2.xml", "spec/examples/rfc748.md.xml")
    expect(norm(File.read("spec/examples/rfc748.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc748.md.xml.txt"))
  end
  it "processes rfc7511 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc7511.md.adoc")
    text_compare("spec/examples/rfc7511.md.2.xml", "spec/examples/rfc7511.md.xml")
    expect(norm(File.read("spec/examples/rfc7511.md.2.xml.txt"))).to be_equivalent_to norm(File.read("spec/examples/rfc7511.md.xml.txt"))
  end
end
