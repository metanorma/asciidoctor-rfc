require "date"
require "nokogiri"
require "htmlentities"

module Asciidoctor
  module RFC::Common
    module Base
      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def document_ns_attributes(_doc)
        # ' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        if node.respond_to?(:lineno)
          warn %(asciidoctor: WARNING (#{node.lineno}): converter missing for #{name || node.node_name} node in RFC backend)
        else
          warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        end
        nil
      end

      # Syntax:
      #   = Title
      #   Author
      #   :HEADER
      #
      #   ABSTRACT
      #
      #   NOTE: note
      #
      # @note (boilerplate is ignored)
      def preamble(node)
        result = []

        # NOTE: *list is V3, verse is V2, paragraph is both
        abstractable_contexts = %i{paragraph dlist olist ulist verse open}

        abstract_blocks = node.blocks.take_while do |block|
          abstractable_contexts.include? block.context
        end

        remainder_blocks = node.blocks[abstract_blocks.length..-1]

        result << noko do |xml|
          if abstract_blocks.any?
            xml.abstract do |xml_abstract|
              xml_abstract << abstract_blocks.map(&:render).flatten.join("\n")
            end
          end
          xml << remainder_blocks.map(&:render).flatten.join("\n")
        end

        result << "</front><middle>"
        result
      end

      # TODO: dead code? remove.
      # def authorname(node, suffix)
      #   noko do |xml|
      #     author_attributes = {
      #       fullname: node.attr("author#{suffix}") || node.attr("fullname#{suffix}"),
      #       surname: node.attr("lastname#{suffix}"),
      #       initials: node.attr("forename_initials#{suffix}"),
      #       role: node.attr("role#{suffix}"),
      #     }.reject { |_, value| value.nil? }
      #     xml.author **author_attributes
      #   end
      # end

      # Syntax:
      #   = Title
      #   Author
      #   :area x, y
      def area(node, xml)
        node.attr("area")&.split(/, ?/)&.each do |ar|
          xml.area { |a| a << ar }
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :workgroup x, y
      def workgroup(node, xml)
        node.attr("workgroup")&.split(/, ?/)&.each do |wg|
          xml.workgroup { |w| w << wg }
        end
      end

      # Syntax:
      #   = Title
      #   Author
      #   :keyword x, y
      def keyword(node, xml)
        node.attr("keyword")&.split(/, ?/)&.each do |kw|
          xml.keyword { |k| k << kw }
        end
      end

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          t_attributes = {
            anchor: node.id,
          }
          result << noko { |xml| xml.t result1, **attr_code(t_attributes) }
        end
        result
      end

      def inline_indexterm(node)
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible
          iref_attributes = {
            item: node.text,
          }
          node.text + noko { |xml| xml.iref **attr_code(iref_attributes) }.join
        else
          terms = node.attr "terms"
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}) if terms.size > 2
          iref_attributes = {
            item: terms[0],
            subitem: (terms.size > 1 ? terms[1] : nil),
          }
          noko { |xml| xml.iref **attr_code(iref_attributes) }.join
        end
      end

      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        result = []
        if node.context == :pass
          node.lines.each do |item|
            # undo XML substitution
            ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
            result << ref
          end
        else
          warn %(asciidoctor: WARNING (#{node.lineno}): references are not raw XML: #{node.context})
        end
        result
      end

      def open(node)
        # open block is a container of multiple blocks, treated as a single block.
        # We append each contained block to its parent
        result = []
        if node.blocks?
          node.blocks.each do |b|
            result << send(b.context, b)
          end
        else
          result = paragraph(node)
        end
        result
      end

      # def dash(camel_cased_word)
      #  camel_cased_word.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
      # end

      def common_rfc_pis(node)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use, common to v2 and v3.
        # These are set only if explicitly specified, with the exception
        # of compact and subcompact
        rfc_pis = {
          artworkdelimiter: node.attr("artworkdelimiter"),
          artworklines: node.attr("artworklines"),
          authorship: node.attr("authorship"),
          autobreaks: node.attr("autobreaks"),
          background: node.attr("background"),
          colonspace: node.attr("colonspace"),
          comments: node.attr("comments"),
          docmapping: node.attr("docmapping"),
          editing: node.attr("editing"),
          emoticonic: node.attr("emoticonic"),
          footer: node.attr("footer"),
          header: node.attr("header"),
          inline: node.attr("inline"),
          iprnotified: node.attr("iprnotified"),
          linkmailto: node.attr("linkmailto"),
          linefile: node.attr("linefile"),
          notedraftinprogress: node.attr("notedraftinprogress"),
          private: node.attr("private"),
          refparent: node.attr("refparent"),
          rfcedstyle: node.attr("rfcedstyle"),
          slides: node.attr("slides"),
          "text-list-symbols": node.attr("text-list-symbols"),
          tocappendix: node.attr("tocappendix"),
          tocindent: node.attr("tocindent"),
          tocnarrow: node.attr("tocnarrow"),
          tocompact: node.attr("tocompact"),
          topblock: node.attr("topblock"),
          useobject: node.attr("useobject"),

          # give errors regarding ID-nits and DTD validation
          strict: node.attr("strict") || "yes",

          # Vertical whitespace control
          # (using these PIs as follows is recommended by the RFC Editor)

          # do not start each main section on a new page
          compact: node.attr("compact") || "yes",
          # keep one blank line between list items
          subcompact: node.attr("subcompact") || "no",

          # TOC control
          # generate a ToC
          toc: node.attr("toc-include") == "false" ? "no" : "yes",

          # the number of levels of subsections in ToC. default: 3
          tocdepth: node.attr("toc-depth") || "4",

          # use anchors rather than numbers for references
          symrefs: node.attr("sym-refs") || "yes",
          # sort references
          sortrefs: node.attr("sort-refs") || "yes",
        }

        attr_code(rfc_pis)
      end

      def set_pis(node, doc)
        # Below are generally applicable Processing Instructions (PIs)
        # that most I-Ds might want to use. (Here they are set differently than
        # their defaults in xml2rfc v1.32)

        if node.attr("rfc2629xslt") == "true"
          pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet",
                                                        'type="text/xsl" href="rfc2629.xslt"')
          doc.root.add_previous_sibling(pi)
        end

        doc.create_internal_subset("rfc", nil, "rfc2629.dtd")
        extract_entities(doc).each do |entity|
          Nokogiri::XML::EntityDecl::new(entity[:entity], doc, 
                                         Nokogiri::XML::EntityDecl::EXTERNAL_GENERAL_PARSED, 
                                         nil, entity[:url], nil)
          entity[:node].replace(Nokogiri::XML::EntityReference.new(doc, entity[:entity]))
        end

        rfc_pis = common_rfc_pis(node)
        rfc_pis.each_pair do |k, v|
          pi = Nokogiri::XML::ProcessingInstruction.new(doc,
                                                        "rfc",
                                                        "#{k}=\"#{v}\"")
          doc.root.add_previous_sibling(pi)
        end

        doc
      end

      # extract references which can be expressed as externally defined entities
      def extract_entities(xmldoc)
        refs = xmldoc.xpath("//reference")
        ret = []
        bibxml2 = bibxml2()
        refs.each do |ref|
          next if ref.parent.name == "referencegroup"
          if ref["anchor"] =~ /^RFC\d+$/
            ret << { entity: ref["anchor"], 
                     node: ref,
                     url: "http://xml2rfc.ietf.org/public/rfc/bibxml/reference.#{ref["anchor"]}.xml".
                     gsub(/reference\.RFC(\d+)/, "reference.RFC.\\1") }
          elsif ref["anchor"] =~ /^I-D\./
            # contra https://xml2rfc.tools.ietf.org, there appears to be no provision for draft versions
            ret << { entity: ref["anchor"], 
                     node: ref,
                     url: "http://xml2rfc.ietf.org/public/rfc/bibxml3/reference.#{ref["anchor"]}.xml" }
          elsif ref["anchor"] =~ /^W3C\./
            ret << { entity: ref["anchor"], 
                     node: ref,
                     url: "http://xml2rfc.ietf.org/public/rfc/bibxml4/reference.#{ref["anchor"]}.xml" }
          elsif ref["anchor"] =~ /^(SDO-)?3GPP\./
            ret << { entity: ref["anchor"], 
                     node: ref,
                     url: "http://xml2rfc.ietf.org/public/rfc/bibxml5/reference.#{ref["anchor"]}.xml" }
          elsif bibxml2.include? ref["anchor"] 
            ret << { entity: ref["anchor"], 
                     node: ref,
                     url: "http://xml2rfc.ietf.org/public/rfc/bibxml2/reference.#{ref["anchor"]}.xml" }
          end
        end
        ret
      end


      # if node contains blocks, flatten them into a single line
      def flatten(node)
        result = []
        result << node.text if node.respond_to?(:text)
        if node.blocks?
          node.blocks.each { |b| result << flatten(b) }
        else
          result << node.content
        end
        result.reject(&:empty?)
      end

      # if node contains blocks, flatten them into a single line; and extract only raw text
      def flatten_rawtext(node)
        result = []
        if node.respond_to?(:blocks) && node.blocks?
          node.blocks.each { |b| result << flatten_rawtext(b) }
        elsif node.respond_to?(:lines)
          node.lines.each do |x|
            result << if node.respond_to?(:context) && (node.context == :literal || node.context == :listing)
                        x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
            else
              # strip not only HTML tags <tag>, but also Asciidoc crossreferences <<xref>>
              x.gsub(/<[^>]*>+/, "")
            end
          end
        elsif node.respond_to?(:text)
          result << node.text.gsub(/<[^>]*>+/, "")
        else
          result << node.content.gsub(/<[^>]*>+/, "")
        end
        result.reject(&:empty?)
      end

      # block for processing XML document fragments as XHTML, to allow for HTMLentities
      def noko(&block)
        # fragment = ::Nokogiri::XML::DocumentFragment.parse("")
        # fragment.doc.create_internal_subset("xml", nil, "xhtml.dtd")
        head = <<HERE
        <!DOCTYPE html SYSTEM
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <title></title>
        <meta charset="UTF-8" />
        </head>
        <body>
        </body>
        </html>
HERE
        doc = ::Nokogiri::XML.parse(head)
        fragment = doc.fragment("")
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml(encoding: "US-ASCII").lines.map { |l| l.gsub(/\s*\n/, "") }
      end

      def attr_code(attributes)
        attributes = attributes.reject { |_, val| val.nil? }.map
        attributes.map do |k, v|
          [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
        end.to_h
      end

      def bibxml2
        %w{
ANSI.T1-102.1987
ANSI.T1-105-02.1993
ANSI.T1-105-02.1998
ANSI.T1-105.1988
ANSI.T1-105.1991
ANSI.T1-105.1995
ANSI.T1-106.1988
ANSI.T1-107.1988
ANSI.T1-231.1993
ANSI.T1-231.1997
ANSI.T1-403.1989
ANSI.T1-404.1989
ANSI.T1-413.1995
ANSI.T1-607.1998
ANSI.T1-617.1991
ANSI.T1-618.1991
ANSI.T1-M1.1993
ANSI.T1-S1.1990
ANSI.X3-4.1968
ANSI.X3-4.1977
ANSI.X3-4.1986
ANSI.X3-16.1976
ANSI.X3-28.1976
ANSI.X3-41.1974
ANSI.X3-51.1975
ANSI.X3-66.1979
ANSI.X3-92.1980
ANSI.X3-92.1981
ANSI.X3-106.1983
ANSI.X3-122.1986
ANSI.X3-124.1985
ANSI.X3-183.1991
ANSI.X3-210.1992
ANSI.X3-216.1992
ANSI.X3-218.1993
ANSI.X3-222.1993
ANSI.X3-230.1994
ANSI.X3-241.1994
ANSI.X3-272.1996
ANSI.X3-288.1996
ANSI.X3-297.1996
ANSI.X3-303.1998
ANSI.X3S3-3.1987
ANSI.X3S3-3.1990
ANSI.X3T9.1984
ANSI.X3T9.1990
ANSI.X9-9.1986
ANSI.X9-17.1985
ANSI.X9-44.1993
ANSI.X9-52.1998
ANSI.X9-55.1995
ANSI.X125.1997
ANSI.X126.1997
ANSI.Z30-50.1992
ANSI.Z39-50.1992
ANSI.Z39-50.1995
CCITT.E163.1988
CCITT.E164.1988
CCITT.E164.1991
CCITT.E166.1988
CCITT.F401.1992
CCITT.G703.1988
CCITT.G704.1988
CCITT.G706.1988
CCITT.G707.1990
CCITT.G707.1992
CCITT.G708.1990
CCITT.G708.1992
CCITT.G709.1990
CCITT.G709.1992
CCITT.G711.1972
CCITT.G726.1990
CCITT.G732.1988
CCITT.G783.1992
CCITT.G821.1988
CCITT.I331.1988
CCITT.I465.1988
CCITT.O162.1988
CCITT.Q920.1984
CCITT.Q921.1984
CCITT.Q922.1991
CCITT.Q922.1992
CCITT.T4.1980
CCITT.T4.1988
CCITT.T30.1977
CCITT.T30.1988
CCITT.T411.1988
CCITT.V120.1993
CCITT.X3.1984
CCITT.X25.1976
CCITT.X25.1980
CCITT.X25.1981
CCITT.X25.1984
CCITT.X25.1989
CCITT.X121.1978
CCITT.X121.1988
CCITT.X208.1988
CCITT.X209.1988
CCITT.X214.1984
CCITT.X219.1987
CCITT.X224.1984
CCITT.X225.1984
CCITT.X229.1987
CCITT.X400.1984
CCITT.X400.1985
CCITT.X400.1988
CCITT.X400.1992
CCITT.X401.1991
CCITT.X408.1988
CCITT.X409.1984
CCITT.X410.1984
CCITT.X411.1984
CCITT.X411.1988
CCITT.X419.1988
CCITT.X420.1984
CCITT.X420.1988
CCITT.X500.1988
CCITT.X500.1993
CCITT.X501.1988
CCITT.X509.1988
CCITT.X511.1988
CCITT.X518.1988
CCITT.X519.1988
CCITT.X520.1988
CCITT.X521.1988
CCITT.X525.1993
CCITT.X680.1994
CCITT.X680.2002
CCITT.X690.1994
CCITT.X690.2002
FIPS.1-1.1980
FIPS.4.1968
FIPS.5-2.1987
FIPS.6-4.1990
FIPS.35.1975
FIPS.46-1.1988
FIPS.46-2.1993
FIPS.46.1977
FIPS.55-2.1987
FIPS.58.1979
FIPS.59.1979
FIPS.74.1981
FIPS.81.1980
FIPS.95-1.1993
FIPS.98.1983
FIPS.113.1985
FIPS.146-1.1989
FIPS.146-1.1991
FIPS.146.1988
FIPS.146.1990
FIPS.161-1.1993
FIPS.180-1.1994
FIPS.180-1.1995
FIPS.180-2.2002
FIPS.180.1993
FIPS.186-1.1998
FIPS.186.1994
FIPS.197.2001
FIPS.500-20.1977
FIPS.500-61.1980
FIPS.500-166.1989
IANA.application.samlassertion-xml
IANA.application.samlassertion-xml
IANA.application.samlmetadata-xml
IANA.application.samlmetadata-xml
IEEE.754.1985
IEEE.802-1A.1990
IEEE.802-1D.1990
IEEE.802-1D.1991
IEEE.802-1D.1993
IEEE.802-1G.1992
IEEE.802-1Y.1990
IEEE.802-2.1984
IEEE.802-2.1985
IEEE.802-2.1989
IEEE.802-2.1994
IEEE.802-3.1985
IEEE.802-3.1988
IEEE.802-3.1990
IEEE.802-3.1996
IEEE.802-3.1998
IEEE.802-4.1988
IEEE.802-5.1989
IEEE.802-5.1995
IEEE.802-6.1990
IEEE.802-11.1999
IEEE.802-11A.1999
IEEE.802-11B.1999
IEEE.802-11D.2001
IEEE.802-11F.2003
IEEE.802-11G.2003
IEEE.802-11H.2003
IEEE.802-11I.2004
IEEE.802-12.1995
IEEE.802.1990
IEEE.1003-1G.1997
IEEE.1003-2.1992
IEEE.1278-1.1995
IEEE.1278-2.1995
IEEE.1284-1.1997
IEEE.1394.1995
IEEE.P802-1A.1989
IEEE.P802-1Q.1998
IEEE.P802-3K.1992
IEEE.P802-3P.1992
IEEE.P802-5D.1989
IEEE.P1363.1998
IEEE.P1394A.1995
IEEE.P1394B.1995
IEEE.P8021A.1989
IEEE.P8021D.1989
ISO.639.1988
ISO.646.1983
ISO.646.1991
ISO.1000.1992
ISO.3166-1.2006
ISO.1745.1975
ISO.2014.1975
ISO.2022.1986
ISO.2022.1994
ISO.2111.1973
ISO.2375.1990
ISO.2628.1973
ISO.2629.1973
ISO.3166.1981
ISO.3166.1984
ISO.3166.1988
ISO.3297.2007
ISO.3307.1975
ISO.3309-AM2.1992
ISO.3309.1979
ISO.3309.1982
ISO.3309.1984
ISO.3309.1991
ISO.4031.1978
ISO.4217.1981
ISO.4335-AD1.1979
ISO.4335.1977
ISO.4335.1979
ISO.4335.1982
ISO.4335.1991
ISO.6429.1988
ISO.6429.1992
ISO.6523.1984
ISO.7489.1984
ISO.7498-2.1984
ISO.7498-2.1988
ISO.7498-3.1989
ISO.7498-4.1984
ISO.7498-4.1989
ISO.7498-4.1994
ISO.7498-AD1.1984
ISO.7498-AD1.1986
ISO.7498.1981
ISO.7498.1984
ISO.7776.1986
ISO.7776.1988
ISO.7809.1984
ISO.7812-1.2000
ISO.8072-AD1.1986
ISO.8072.1984
ISO.8072.1985
ISO.8072.1986
ISO.8073.1984
ISO.8073.1985
ISO.8073.1986
ISO.8208.1984
ISO.8208.1985
ISO.8208.1987
ISO.8208.1988
ISO.8208.1990
ISO.8326.1990
ISO.8327.1984
ISO.8327.1990
ISO.8348-AD1.1987
ISO.8348-AD2.1988
ISO.8348-AM5.1994
ISO.8348.1987
ISO.8348.1992
ISO.8348.1993
ISO.8372.1987
ISO.8473-1.1994
ISO.8473-AD3.1989
ISO.8473.1986
ISO.8473.1987
ISO.8473.1988
ISO.8473.1989
ISO.8473.1990
ISO.8473.1992
ISO.8473.1993
ISO.8509.1987
ISO.8571-1.1988
ISO.8571-2.1988
ISO.8571-3.1988
ISO.8571-4.1988
ISO.8571-5.1988
ISO.8583.1993
ISO.8601.1988
ISO.8602.1986
ISO.8602.1987
ISO.8613.1989
ISO.8648.1988
ISO.8649.1987
ISO.8649.1989
ISO.8650.1988
ISO.8650.1989
ISO.8802-2.1989
ISO.8802-5.1992
ISO.8802-5.1995
ISO.8802.1988
ISO.8822.1987
ISO.8822.1988
ISO.8822.1989
ISO.8823.1988
ISO.8823.1989
ISO.8824.1987
ISO.8824.1988
ISO.8824.1989
ISO.8824.1990
ISO.8825-2.1996
ISO.8825.1987
ISO.8825.1988
ISO.8825.1990
ISO.8859-1.1987
ISO.8859-6.1988
ISO.8859-7.1987
ISO.8859-8.1988
ISO.8859.1992
ISO.8859.2003
ISO.8878.1987
ISO.8879.1986
ISO.8879.1988
ISO.8885.1993
ISO.9072-1.1987
ISO.9072-2.1987
ISO.9074.1989
ISO.9314-1.1988
ISO.9314-1.1989
ISO.9314-2.1988
ISO.9314-2.1989
ISO.9542-AD.1991
ISO.9542.1987
ISO.9542.1988
ISO.9548.1989
ISO.9575.1989
ISO.9576.1989
ISO.9577.1990
ISO.9577.1996
ISO.9577.1999
ISO.9594-1.1987
ISO.9594-1.1988
ISO.9594-2.1987
ISO.9594-2.1993
ISO.9594-6.1987
ISO.9594-8.1987
ISO.9594-8.1993
ISO.9594-8.1995
ISO.9594-9.1990
ISO.9594.1988
ISO.9594.1989
ISO.9594.1990
ISO.9595.1988
ISO.9595.1990
ISO.9596.1988
ISO.9596.1990
ISO.9735.1991
ISO.9735.1993
ISO.9798-3.1993
ISO.9834-1.1993
ISO.9899.1990
ISO.9945-2-2.1991
ISO.10021.1988
ISO.10035.1989
ISO.10038.1993
ISO.10039.1990
ISO.10160.1997
ISO.10161-1.1997
ISO.10162.1992
ISO.10163.1992
ISO.10175-1.1996
ISO.10589.1990
ISO.10589.1992
ISO.10646-1-AD2.1996
ISO.10646-1.1993
ISO.10744.1992
ISO.10747.1993
ISO.11188-1.1994
ISO.11572-2.1997
ISO.11578.1996
ISO.13213.1994
ISO.13818-6.1995
ISO.27729.2012
ITU.BT709.1990
ITU.E164.1991
ITU.F185.1998
ITU.G707.1996
ITU.G826.1995
ITU.H223.1996
ITU.H225.1996
ITU.H245.1996
ITU.H245.1998
ITU.H323.1996
ITU.H323.1998
ITU.H323v3.1999
ITU.H324.1996
ITU.H341.1999
ITU.I361.1993
ITU.I363-5.1996
ITU.I363.1993
ITU.I365-1.1993
ITU.I555.1997
ITU.Q761.1994
ITU.Q762.1994
ITU.Q931.1993
ITU.Q931.1998
ITU.Q2630-1.1999
ITU.Q2931.1994
ITU.T4.1996
ITU.T6.1984
ITU.T30.1996
ITU.T37.1998
ITU.T38.1998
ITU.T42.1996
ITU.T43.1997
ITU.T44.1999
ITU.T81.1992
ITU.T82.1993
ITU.T85.1995
ITU.T140.1998
ITU.V18.1998
ITU.V42.1994
ITU.X224.1993
ITU.X411.1998
ITU.X420.1996
ITU.X500.1993
ITU.X500.1997
ITU.X500.2001
ITU.X501.1993
ITU.X501.1997
ITU.X501.2001
ITU.X509.1997
ITU.X509.2000
ITU.X511.1993
ITU.X511.1997
ITU.X511.2001
ITU.X518.1993
ITU.X518.1997
ITU.X518.2001
ITU.X519.1993
ITU.X519.1997
ITU.X519.2001
ITU.X520.1993
ITU.X520.1996
ITU.X520.1997
ITU.X520.2001
ITU.X521.1993
ITU.X521.1996
ITU.X521.1997
ITU.X521.2001
ITU.X525.1993
ITU.X525.1997
ITU.X525.2001
ITU.X530.1997
ITU.X530.2001
ITU.X690.1994
ITU.X744.1996
NIST.500-20.1977
NIST.500-61.1980
NIST.500-162.1988
NIST.500-162.1990
NIST.500-163.1989
NIST.500-166.1989
NIST.500-183.1990
NIST.500-214.1993
OASIS.saml-authn-context-2.0-os
OASIS.saml-bindings-2.0-os
OASIS.saml-conformance-2.0-os
OASIS.saml-core-2.0-os
OASIS.saml-glossary-2.0-os
OASIS.saml-metadata-2.0-os
OASIS.saml-profiles-2.0-os
OASIS.saml-sec-consider-2.0-os
OASIS.sstc-core
OASIS.sstc-saml-exec-overview-2.0-cd-01
OASIS.sstc-saml-tech-overview-2.0-draft-08
OASIS.sstc-saml-tech-overview-2.0-draft-10
OASIS.sstc-saml-tech-overview-2.0-draft-16
OASIS.xacml-schema-policy
PKCS.1.1991
PKCS.1.1993
PKCS.3.1993
PKCS.6.1993
PKCS.7.1993
PKCS.8.1993
PKCS.9.1993
PKCS.12.1997
W3C.CR-rdf-schema
W3C.daml+oil-reference
W3C.DSig-label
W3C.P3P-rdfschema
W3C.P3P
W3C.PICS-labels
W3C.PICS-rules
W3C.PICS-services
W3C.REC-rdf-syntax
W3C.REC-RUBY
W3C.REC-XHTML
W3C.REC-xml-1998
W3C.REC-xml-names
W3C.REC-xml
W3C.REC-xmlenc-core
W3C.REC-xmlschema-1
W3C.REC-xmlschema-2
W3C.REC-xslt
W3C.soap11
W3C.soap12-part1
W3C.soap12-part2
W3C.xkms
W3C.xml-c14n
W3C.xmldsig-core
W3C.xmlenc-core
W3C.xpath
        }
      end
    end
  end
end
