require "spec_helper"

def text_compare(old_xml, new_xml)
  File.write("#{old_xml}.1", norm(File.read(old_xml, encoding: "utf-8")))
  File.write("#{new_xml}.1", norm(File.read(new_xml, encoding: "utf-8")))
  system("xml2rfc #{old_xml}.1 -o #{old_xml}.txt")
  system("xml2rfc #{new_xml}.1 -o #{new_xml}.txt")
end

def text_compare1(old_xml, new_xml)
  system("xml2rfc #{old_xml} -o #{old_xml}.txt")
  system("xml2rfc #{new_xml} -o #{new_xml}.txt")
end

def norm(text)
  text.gsub(%r{<spanx style="strong">(MUST|MUST\s+NOT|REQUIRED|SHALL|SHALL\s+NOT|SHOULD|SHOULD\s+NOT|NOT\s+RECOMMENDED|RECOMMENDED|MAY|OPTIONAL)</spanx>}m, "\\1").
    gsub(%r{<t hangText="([^"]+:) ">}, '<t hangText="\\1">').
    gsub(%r{<date year="2009" month="July" day="05"/>}, '<date year="2009" month="July" day="5"/>').
    gsub(%r{<date year="2017" month="November" day="03"/>}, '<date year="2017" month="November" day="3"/>').
    gsub(%r{<author fullname="Editor name"}, '<author fullname="Editor Name"').
    gsub(%r{<t>(Tables use ttcol to define column headers and widths[^<]+)</t>(\s*<texttable[^>]+>)}m, "<postamble>\\2</postamble>\\1").
    gsub(%r{<t>(These are sometimes called "inert" gasses[^<]+)</t>(\s*<texttable[^>]+>)}m, "\\2<preamble>\\1</preamble>").
    gsub(%r{(</texttable>\s*)<t>(which is a very simple example\.)</t>}, "<postamble>\\2</postamble>\\1").
    gsub(%r{(</texttable>\s*)<t>(Source: Chemistry 101)</t>}, "<postamble>\\2</postamble>\\1").
    gsub(%r{(<t hangText="Option Type">\s*<vspace />\s*)<vspace/>\s*(8-bit identifier of the type of option)}, "\\1\\2").
    gsub(%r{(<t hangText="Option Length">\s*<vspace />\s*)<vspace/>\s*(8-bit unsigned integer\.  The length of the option)}, "\\1\\2").
    gsub(%r{(<t hangText="SRO Param">\s*<vspace />\s*)<vspace/>\s*(8-bit identifier indicating Scenic Routing parameters)}, "\\1\\2").
    gsub(%r{<vspace blankLines="0"/>(The highest-order two bits)}, "\\1").
    gsub(%r{<vspace blankLines="0"/>(The following BIT)}, "\\1").
    gsub(%r{<vspace blankLines="0"/>(The following two bits)}, "\\1").
    gsub(%r{<vspace blankLines="0"/>(The lowest-order two bits)}, "\\1").
    gsub(%r{ width="25%">Name</ttcol>}, ">Name</ttcol>").
    gsub(%r{ width="25%">Atomic Number</ttcol>}, ">Atomic Number</ttcol>").
    gsub(%r{&RFC6949;}, '<reference anchor="RFC6949"> <front> <title>RFC Series Format Requirements and Future Development</title> <author initials="H." surname="Flanagan" fullname="H. Flanagan"> <organization/></author> <author initials="N." surname="Brownlee" fullname="N. Brownlee"> <organization/></author> <date year="2013" month="May"/> </front> <seriesInfo name="RFC" value="6949"/> <annotation>This is a primary reference work.</annotation> </reference>').
    gsub(%r{ width="25%">Name</ttcol>}, ">Name</ttcol>").
    gsub(%r{ width="25%">Atomic Number</ttcol>}, ">Atomic Number</ttcol>").
    gsub(%r{title="IAB Members at the Time of Approval" numbered="no">}, 'title="IAB Members at the Time of Approval">').
    gsub(%r{title="Acknowledgments" numbered="no">}, 'title="Acknowledgments">').
    gsub(%r{target='http://www.rfc-editor.org/info/}, "target='https://www.rfc-editor.org/info/").
    gsub(%r{target="http://www.rfc-editor.org/info/}, 'target="https://www.rfc-editor.org/info/').
    gsub(%r{<\?rfc subcompact="yes" \?>\s*<list>(\s*<t>Jari Arkko</t>)}m, %{<list style="symbols">\n\\1}).
    gsub(%r{&W3C.REC-CSS2-20110607;}, '<reference anchor="W3C.REC-CSS2-20110607" target="http://www.w3.org/TR/2011/REC-CSS2-20110607"> <front> <title>Cascading Style Sheets Level 2 Revision 1 (CSS 2.1) Specification</title> <author initials="B." surname="Bos" fullname="Bert Bos"> <organization/> </author> <author initials="T." surname="Celik" fullname="Tantek Celik"> <organization/> </author> <author initials="I." surname="Hickson" fullname="Ian Hickson"> <organization/> </author> <author initials="H." surname="Lie" fullname="Hakon Wium Lie"> <organization/> </author> <date month="June" day="7" year="2011"/> </front> <seriesInfo name="World Wide Web Consortium Recommendation" value="REC-CSS2-20110607"/> <format type="HTML" target="http://www.w3.org/TR/2011/REC-CSS2-20110607"/> </reference>').
    gsub(%r{&W3C.REC-html5-20141028;}, "<reference anchor='W3C.REC-html5-20141028' target='http://www.w3.org/TR/2014/REC-html5-20141028'> <front> <title>HTML5</title> <author initials='I.' surname='Hickson' fullname='Ian Hickson'> <organization /> </author> <author initials='R.' surname='Berjon' fullname='Robin Berjon'> <organization /> </author> <author initials='S.' surname='Faulkner' fullname='Steve Faulkner'> <organization /> </author> <author initials='T.' surname='Leithead' fullname='Travis Leithead'> <organization /> </author> <author initials='E.' surname='Navara' fullname='Erika Doyle Navara'> <organization /> </author> <author initials='T.' surname='O&#039;Connor' fullname='Theresa O&#039;Connor'> <organization /> </author> <author initials='S.' surname='Pfeiffer' fullname='Silvia Pfeiffer'> <organization /> </author> <date month='October' day='28' year='2014' /> </front> <seriesInfo name='World Wide Web Consortium Recommendation' value='REC-html5-20141028' /> <format type='HTML' target='http://www.w3.org/TR/2014/REC-html5-20141028' /> </reference>")
end

def remove_pages(text)
  text.gsub(%r{\n+\S+     [^\n]+\[Page \d+\]\n.?\nRFC[^\n]+\n}, "\n").gsub(%r{\n\n\n+}, "\n\n")
end

def text_compare2(old_xml, new_xml)
  File.write("#{old_xml}.1", norm(File.read(old_xml, encoding: "utf-8")))
  File.write("#{new_xml}.1", norm(File.read(new_xml, encoding: "utf-8")))
  system("xml2rfc #{old_xml}.1 -o #{old_xml}.txt.1")
  system("xml2rfc #{new_xml}.1 -o #{new_xml}.txt.1")
  File.write("#{old_xml}.txt", remove_pages(File.read("#{old_xml}.txt.1", encoding: "utf-8")))
  File.write("#{new_xml}.txt", remove_pages(File.read("#{new_xml}.txt.1", encoding: "utf-8")))
end

describe Asciidoctor::RFC::V2::Converter do
  # it "processes RFC 6350 RFC XML v2 example with bibliography preprocessing, with equivalent text" do
  #  system("asciidoctor -b rfc2 -r 'asciidoctor-bibliography' -r 'asciidoctor-rfc' ./spec/examples/rfc6350.adoc -o spec/examples/rfc6350.xml")
  #  text_compare2("spec/examples/rfc6350.xml", "spec/examples/rfc6350.xml")
  #  expect(File.read("spec/examples/rfc6350.xml.txt")).to eq(File.read("spec/examples/rfc6350.txt.orig"))
  # end
  it "processes Davies template with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/davies-template-bare-06.adoc")
    text_compare("spec/examples/davies-template-bare-06.xml.orig", "spec/examples/davies-template-bare-06.xml")
    expect(norm(File.read("spec/examples/davies-template-bare-06.xml.orig.txt"))).to eq(norm(File.read("spec/examples/davies-template-bare-06.xml.txt")))
  end
  it "processes MIB template with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/mib-doc-template-xml-06.adoc")
    text_compare("spec/examples/mib-doc-template-xml-06.xml.orig", "spec/examples/mib-doc-template-xml-06.xml")
    expect(norm(File.read("spec/examples/mib-doc-template-xml-06.xml.orig.txt"))).to eq(norm(File.read("spec/examples/mib-doc-template-xml-06.xml.txt")))
  end
  it "processes rfc1149 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc1149.md.adoc")
    text_compare("spec/examples/rfc1149.md.2.xml", "spec/examples/rfc1149.md.xml")
    expect(norm(File.read("spec/examples/rfc1149.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc1149.md.xml.txt")))
  end
  it "processes rfc2100 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc2100.md.adoc")
    text_compare("spec/examples/rfc2100.md.2.xml", "spec/examples/rfc2100.md.xml")
    expect(norm(File.read("spec/examples/rfc2100.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc2100.md.xml.txt")))
  end
  it "processes rfc3514 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc3514.md.adoc")
    text_compare("spec/examples/rfc3514.md.2.xml", "spec/examples/rfc3514.md.xml")
    expect(norm(File.read("spec/examples/rfc3514.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc3514.md.xml.txt")))
  end
  it "processes rfc5841 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc5841.md.adoc")
    text_compare("spec/examples/rfc5841.md.2.xml", "spec/examples/rfc5841.md.xml")
    expect(norm(File.read("spec/examples/rfc5841.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc5841.md.xml.txt")))
  end
  it "processes rfc748 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc748.md.adoc")
    text_compare("spec/examples/rfc748.md.2.xml", "spec/examples/rfc748.md.xml")
    expect(norm(File.read("spec/examples/rfc748.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc748.md.xml.txt")))
  end
  it "processes rfc7511 from Markdown with equivalent text" do
    # leaving out step of running ./mmark
    system("bin/asciidoctor-rfc2 spec/examples/rfc7511.md.adoc")
    text_compare("spec/examples/rfc7511.md.2.xml", "spec/examples/rfc7511.md.xml")
    expect(norm(File.read("spec/examples/rfc7511.md.2.xml.txt"))).to eq(norm(File.read("spec/examples/rfc7511.md.xml.txt")))
  end
  it "processes draft-ietf-core-block-xx from Kramdown with equivalent text" do
    # leaving out step of running ./kramdown
    system("bin/asciidoctor-rfc2 spec/examples/draft-ietf-core-block-xx.mkd.adoc")
    text_compare("spec/examples/draft-ietf-core-block-xx.xml.orig", "spec/examples/draft-ietf-core-block-xx.mkd.xml")
    expect(norm(File.read("spec/examples/draft-ietf-core-block-xx.xml.orig.txt"))).to eq(norm(File.read("spec/examples/draft-ietf-core-block-xx.mkd.xml.txt")))
  end
  it "processes skel from Kramdown with equivalent text" do
    # leaving out step of running ./kramdown
    system("bin/asciidoctor-rfc2 spec/examples/skel.mkd.adoc")
    text_compare("spec/examples/skel.xml.orig", "spec/examples/skel.mkd.xml")
    expect(File.read("spec/examples/skel.xml.orig.txt")).to eq(File.read("spec/examples/skel.mkd.xml.txt"))
  end
  it "processes stupid-s from Kramdown with equivalent text" do
    # leaving out step of running ./kramdown
    system("bin/asciidoctor-rfc2 spec/examples/stupid-s.mkd.adoc")
    text_compare("spec/examples/stupid-s.xml.orig", "spec/examples/stupid-s.mkd.xml")
    expect(File.read("spec/examples/stupid-s.xml.orig.txt")).to eq(File.read("spec/examples/stupid-s.mkd.xml.txt"))
  end
  it "processes Hoffman RFC XML v2 example with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/hoffmanv2.xml.adoc")
    text_compare("spec/examples/hoffmanv2.xml.orig", "spec/examples/hoffmanv2.xml.xml")
    expect(norm(File.read("spec/examples/hoffmanv2.xml.orig.txt"))).to eq(norm(File.read("spec/examples/hoffmanv2.xml.xml.txt")))
  end
  it "processes draft-iab-rfc-framework-bis RFC XML v2 example with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/draft-iab-rfc-framework-bis.xml.adoc")
    text_compare("spec/examples/draft-iab-rfc-framework-bis.xml.orig", "spec/examples/draft-iab-rfc-framework-bis.xml.xml")
    expect(norm(File.read("spec/examples/draft-iab-rfc-framework-bis.xml.orig.txt"))).to eq(norm(File.read("spec/examples/draft-iab-rfc-framework-bis.xml.xml.txt")))
  end
  it "processes draft-iab-html-rfc-bis RFC XML v2 example with equivalent text" do
    system("bin/asciidoctor-rfc2 spec/examples/draft-iab-html-rfc-bis.xml.adoc")
    text_compare("spec/examples/draft-iab-html-rfc-bis.xml.orig", "spec/examples/draft-iab-html-rfc-bis.xml.xml")
    expect(norm(File.read("spec/examples/draft-iab-html-rfc-bis.xml.orig.txt"))).to eq(norm(File.read("spec/examples/draft-iab-html-rfc-bis.xml.xml.txt")))
  end
end
