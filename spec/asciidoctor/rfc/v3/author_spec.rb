require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders all options with short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with multiple short author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      John Doe Horton <john.doe@email.com>; Joanna Diva Munez <joanna.munez@email.com>
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton">
      <address>
      <email>john.doe@email.com</email>
      </address>
      </author>
      <author fullname="Joanna Diva Munez" surname="Munez">
      <address>
      <email>joanna.munez@email.com</email>
      </address>
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with long author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" initials="J. D." surname="Horton" role="editor">
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
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders all options with multiple long author syntax" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      :role_2: author
      :organization_2: IBM
      :fax_2: 555 6666
      :email_2: billy.thornton@email.com
      :uri_2: http://ibm.com
      :phone_2: 555 6655
      :street_2: 67 Mt Pleasant St
      :city_2: Dulltown
      :region_2: VIC
      :country_2: UK
      :code_2: 44444
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" initials="J. D." surname="Horton" role="editor">
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
      <author fullname="Billy Bob Thornton" initials="B. B." surname="Thornton" role="author">
      <organization>IBM</organization>
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
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "respects multiple lines in street" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" initials="J. D." surname="Horton" role="editor">
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
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "ignores initials attribute from Asciidoc" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
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
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "permits corporate authors" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
               version="3" submissionType="IETF">
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
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "respects postal line attributes, with multiple lines" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      :postal-line: 57 Mt Pleasant St\ Dullsville\ NSW\ Australia\ 3333
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" role="editor">
      <organization>Ribose</organization>
      <address>
      <postal>
      <postalLine>57 Mt Pleasant St</postalLine>
      <postalLine>Dullsville</postalLine>
      <postalLine>NSW</postalLine>
      <postalLine>Australia</postalLine>
      <postalLine>3333</postalLine>
      </postal>
      <phone>555 5655</phone>
      <facsimile>555 5555</facsimile>
      <email>john.doe@email.com</email>
      <uri>http://example.com</uri>
      </address>
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end

  it "gives postal lines priority over address lines" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
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
      :postal-line: 57 Mt Pleasant St\ Dullsville\ NSW\ Australia\ 3333
      :street: 57 Mt Pleasant St
      :city: Dullsville
      :region: NSW
      :country: Australia
      :code: 3333
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc preptime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="John Doe Horton" surname="Horton" role="editor">
      <organization>Ribose</organization>
      <address>
      <postal>
      <postalLine>57 Mt Pleasant St</postalLine>
      <postalLine>Dullsville</postalLine>
      <postalLine>NSW</postalLine>
      <postalLine>Australia</postalLine>
      <postalLine>3333</postalLine>
      </postal>
      <phone>555 5655</phone>
      <facsimile>555 5555</facsimile>
      <email>john.doe@email.com</email>
      <uri>http://example.com</uri>
      </address>
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
end
