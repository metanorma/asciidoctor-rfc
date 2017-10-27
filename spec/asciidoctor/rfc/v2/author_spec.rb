require "spec_helper"
describe Asciidoctor::RFC::V2::Converter do
  it "renders all options with short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>
         
      == Section 1
      text
 INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

       <?rfc strict="yes"?>
       <?rfc toc="yes"?>
       <?rfc tocdepth="4"?>
       <?rfc symrefs="yes"?>
       <?rfc sortrefs="yes"?>
       <?rfc compact="yes"?>
       <?rfc subcompact="no"?>
      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton">
         <address>
             <postal>
               <street/>
             </postal>
           <email>john.doe@email.com</email>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with multiple short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>; Joanna Diva Munez <joanna.munez@email.com>
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton">
         <address>
             <postal>
               <street/>
             </postal>
           <email>john.doe@email.com</email>
         </address>
      </author>
      <author fullname="Joanna Diva Munez" surname="Munez">
         <address>
             <postal>
               <street/>
             </postal>
           <email>joanna.munez@email.com</email>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with long author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      :fullname: John Doe Horton
      :lastname: Horton
      :forename_initials: J. D.
      :role: editor
      :organization: Ribose
      :organization_abbrev: RBM
      :fax: 555 5555
      :email: john.doe@email.com
      :uri: http://example.com
      :phone: 555 5655
      :street: 57 Mt Pleasant St
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" initials="J. D." role="editor">
         <organization abbrev="RBM">Ribose</organization>
         <address>
           <postal>
             <street>57 Mt Pleasant St</street>
             <city>Dullsville</city>
             <region>NSW</region>
             <code>3333</code>
             <country>Australia</country>
           </postal>
           <phone>555 5655</phone>
           <facsimile>555 5555</facsimile>
           <email>john.doe@email.com</email>
           <uri>http://example.com</uri>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "deals with entities for all options under long author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :fullname: John <Doe> Horton
      :lastname: Horton & Horton
      :forename_initials: J. & D.
      :organization: Ribose & co.
      :organization_abbrev: RBM & co.
      :fax: <555 5555>
      :email: <john.doe@email.com>
      :uri: http://example.com?x&y
      :phone: 555 5655 & 999
      :street: Cnr Mt Pleasant St & Dullsvile Cnr
      :city: Dullsville & Pleasantville
      :region: NSW & ACT
      :country: Australia & New Zealand
      :code: 3333 & 3334
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
         <author fullname="John &lt;Doe&gt; Horton" surname="Horton &amp; Horton" initials="J. &amp; D.">
           <organization abbrev="RBM &amp; co.">Ribose &amp; co.</organization>
           <address>
             <postal>
               <street>Cnr Mt Pleasant St &amp; Dullsvile Cnr</street>
               <city>Dullsville &amp; Pleasantville</city>
               <region>NSW &amp; ACT</region>
               <code>3333 &amp; 3334</code>
               <country>Australia &amp; New Zealand</country>
             </postal>
             <phone>555 5655 &amp; 999</phone>
             <facsimile>&lt;555 5555&gt;</facsimile>
             <email>&lt;john.doe@email.com&gt;</email>
             <uri>http://example.com?x&amp;y</uri>
           </address>
         </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with multiple long author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      :fullname: John Doe Horton
      :lastname: Horton
      :forename_initials: J. D.
      :role: editor
      :organization: Ribose
      :fax: 555 5555
      :email: john.doe@email.com
      :uri: http://example.com
      :phone: 555 5655
      :street: 57 Mt Pleasant St
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
      :fullname_2: Billy Bob Thornton
      :lastname_2: Thornton
      :forename_initials_2: B. B.
      :role_2: editor
      :organization_2: International Business Machines
      :organization_abbrev_2: IBM
      :fax_2: 555 6666
      :email_2: billy.thornton@email.com
      :uri_2: http://ibm.com
      :phone_2: 555 6655
      :street_2: 67 Mt Pleasant St
      :city_2: Dulltown
      :region_2: VIC
      :country_2: UK
      :code_2: 44444
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" initials="J. D." role="editor">
         <organization>Ribose</organization>
         <address>
           <postal>
             <street>57 Mt Pleasant St</street>
             <city>Dullsville</city>
             <region>NSW</region>
             <code>3333</code>
             <country>Australia</country>
           </postal>
           <phone>555 5655</phone>
           <facsimile>555 5555</facsimile>
           <email>john.doe@email.com</email>
           <uri>http://example.com</uri>
         </address>
      </author>
      <author fullname="Billy Bob Thornton" surname="Thornton" initials="B. B." role="editor">
         <organization abbrev="IBM">International Business Machines</organization>
         <address>
           <postal>
             <street>67 Mt Pleasant St</street>
             <city>Dulltown</city>
             <region>VIC</region>
             <code>44444</code>
             <country>UK</country>
           </postal>
           <phone>555 6655</phone>
           <facsimile>555 6666</facsimile>
           <email>billy.thornton@email.com</email>
           <uri>http://ibm.com</uri>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "respects multiple lines in street" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      :fullname: John Doe Horton
      :lastname: Horton
      :forename_initials: J. D.
      :role: editor
      :organization: Ribose
      :fax: 555 5555
      :email: john.doe@email.com
      :uri: http://example.com
      :phone: 555 5655
      :street: 57 Mt Pleasant St\ Technology Park
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" initials="J. D." role="editor">
         <organization>Ribose</organization>
         <address>
           <postal>
             <street>57 Mt Pleasant St</street>
             <street>Technology Park</street>
             <city>Dullsville</city>
             <region>NSW</region>
             <code>3333</code>
             <country>Australia</country>
           </postal>
           <phone>555 5655</phone>
           <facsimile>555 5555</facsimile>
           <email>john.doe@email.com</email>
           <uri>http://example.com</uri>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores initials attribute from Asciidoc" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      :fullname: John Doe Horton
      :lastname: Horton
      :initials: J. D. H.
      :role: editor
      :organization: Ribose
      :fax: 555 5555
      :email: john.doe@email.com
      :uri: http://example.com
      :phone: 555 5655
      :street: 57 Mt Pleasant St
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" role="editor">
         <organization>Ribose</organization>
         <address>
           <postal>
             <street>57 Mt Pleasant St</street>
             <city>Dullsville</city>
             <region>NSW</region>
             <code>3333</code>
             <country>Australia</country>
           </postal>
           <phone>555 5655</phone>
           <facsimile>555 5555</facsimile>
           <email>john.doe@email.com</email>
           <uri>http://example.com</uri>
         </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "permits corporate authors" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      :role: editor
      :organization: Ribose
      :fax: 555 5555
      :email: john.doe@email.com
      :uri: http://example.com
      :phone: 555 5655
      :street: 57 Mt Pleasant St
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
      
      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author role="editor">
        <organization>Ribose</organization>
        <address>
          <postal>
            <street>57 Mt Pleasant St</street>
            <city>Dullsville</city>
            <region>NSW</region>
            <code>3333</code>
            <country>Australia</country>
          </postal>
          <phone>555 5655</phone>
          <facsimile>555 5555</facsimile>
          <email>john.doe@email.com</email>
          <uri>http://example.com</uri>
        </address>
      </author>
      <date day="1" month="January" year="1970"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">     
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
