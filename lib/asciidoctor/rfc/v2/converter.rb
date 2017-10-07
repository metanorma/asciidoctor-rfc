require "asciidoctor/rfc/converter"

module Asciidoctor
  module RFC::V2
    # A {Converter} implementation that generates RFC XML 2 output, a format used to
    # format RFC proposals (https://tools.ietf.org/html/rfc7749)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md

    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer
      include ::Asciidoctor::RFC::Converter

      register_for "rfc2"

      $seen_back_matter = false
      $seen_abstract = false
      $xreftext = {}

      def initialize(backend, opts)
        super
        # basebackend 'html'
        outfilesuffix ".xml"
      end

      alias :pass :content
      alias :embedded :content
      alias :sidebar :content
      alias :audio :skip
      alias :colist :skip
      alias :floating_title :skip
      alias :page_break :skip
      alias :thematic_break :skip
      alias :video :skip
      alias :inline_button :skip
      alias :inline_kbd :skip
      alias :inline_menu :skip

      alias :verse :content
      alias :quote :content

      def document(node)
        # =Title
        # Author
        # :category
        # :consensus
        # :doc-name
        # :number
        #
        # :ipr
        # :obsoletes
        # :updates
        # :submissionType
        # :indexInclude
        # :ipr-extract
        # :sort-refs
        # :sym-refs
        # :toc-include
        #
        # ABSTRACT
        #
        # NOTEs
        #
        # ==first title
        # CONTENT
        #
        # [bibliography] # start of back matter
        # == Bibliography
        #
        # [appendix] # start of back matter if not already started
        # == Appendix
        #
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        category = get_header_attribute node, "category"
        consensus = get_header_attribute node, "consensus"
        docName = get_header_attribute node, "docName"
        number = get_header_attribute node, "number"
        warn "asciidoctor: WARNING: both docName and number attributes present" unless number.nil? || docName.nil?
        ipr = get_header_attribute node, "ipr"
        iprExtract = get_header_attribute node, "indexInclude"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        seriesNo = get_header_attribute node, "seriesNo"
        submissionType = get_header_attribute node, "submissionType", "IETF"
        xmllang = get_header_attribute node, "xml:lang"

        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{category}
        #{consensus}#{submissionType}#{iprExtract}#{docName}#{number}#{seriesNo}#{xmllang}>)
        result << (front node)
        result << "</front><middle1>"
        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        result = result.flatten
        if result.any? { |e| e =~ /<\/front><middle>/ } && result.any? { |e| e =~ /<\/front><middle1>/ }
          result = result.reject { |e| e =~ /<\/front><middle1>/ }
        else
          result = result.map { |e| e =~ /<\/front><middle1>/ ? "</front><middle>" : e }
        end

        result * "\n"
      end

      def front(node)
        # = Title
        # Author
        # :METADATA
        result = []
        result << "<front>"
        abbrev = get_header_attribute node, "abbrev"
        result << "<title#{abbrev}>#{node.doctitle}</title>"
        result << (author node)
        result << (date node)
        result << (area node)
        result << (workgroup node)
        result << (keyword node)
      end

      def organization(node, suffix)
        result = []
        organization = node.attr("organization#{suffix}")
        organization_abbrev = node.attr("organization_abbrev#{suffix}")
        abbrev = set_header_attribute "abbrev", organization_abbrev
        result << "<organization#{abbrev}>#{organization}</organization>" unless organization.nil?
        result
      end

      def address(node, suffix)
        result = []
        postalline = nil
        street = node.attr("street#{suffix}")
        city = node.attr("city#{suffix}")
        region = node.attr("region#{suffix}")
        country = node.attr("country#{suffix}")
        code = node.attr("code#{suffix}")
        phone = node.attr("phone#{suffix}")
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        uri = node.attr("uri#{suffix}")
        if (not email.nil?) || (not facsimile.nil?) || (not uri.nil?) || (not phone.nil?) ||
          (not street.nil?)
          result << "<address>"
          if not street.nil?
            result << "<postal>"
            if postalline.nil?
              street&.split("\\ ")&.each { |p| result << "<street>#{p}</street>" }
              result << "<city>#{city}</city>" unless city.nil?
              result << "<region>#{region}</region>" unless region.nil?
              result << "<code>#{code}</code>" unless code.nil?
              result << "<country>#{country}</country>" unless country.nil?
            else
              postalline&.split("\\ ")&.each { |p| result << "<postalLine>#{p}</postalLine>" }
            end
            result << "</postal>"
          end
          result << "<phone>#{phone}</phone>" unless phone.nil?
          result << "<facsimile>#{facsimile}</facsimile>" unless facsimile.nil?
          result << "<email>#{email}</email>" unless email.nil?
          result << "<uri>#{uri}</uri>" unless uri.nil?
          result << "</address>"
        end
        result
      end

      def author(node)
        # = Title
        # Author;Author_2;Author_3
        # :fullname
        # :lastname
        # :organization
        # :email
        # :fullname_2
        # :lastname_2
        # :organization_2
        # :email_2
        # :fullname_3
        # :lastname_3
        # :organization_3
        # :email_3
        # recurse: author, author_2, author_3...
        result = []
        result << author1(node, "")
        i = 2
        loop do
          suffix = "_#{i}"
          author = node.attr("author#{suffix}")
          if author.nil?
            break
          end
          result << author1(node, suffix)
          i += 1
        end
        result.flatten
      end

      def author1(node, suffix)
        # = Title
        # Author (contains author firstname lastname middlename authorinitials email: Firstname Middlename Lastname <Email>)
        # :fullname
        # :lastname
        # :forename_initials (excludes surname, unlike Asciidoc "initials" attribute)
        # :organization
        # :organization_abbrev
        # :email
        # :role
        # :fax
        # :uri
        # :phone
        # :street (lines broken up by "\ ")
        # :city
        # :region
        # :country
        # :code
        result = []
        result << authorname(node, suffix)
        result << organization(node, suffix)
        result << address(node, suffix)
        result << "</author>"
        result
      end

      def date(node)
        # = Title
        # Author
        # :revdate or :date
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        # date is mandatory in v2: use today
        revdate = DateTime.now.iso8601 if revdate.nil?
        warn %(asciidoctor: WARNING: revdate attribute missing from header, provided current date)
        unless revdate.nil?
          begin
            revdate.gsub!(/T.*$/, "")
            d = Date.iso8601 revdate
            day = set_header_attribute "day", d.day
            month = set_header_attribute "month", Date::MONTHNAMES[d.month]
            year = set_header_attribute "year", d.year
            result << "<date#{day}#{month}#{year}/>"
          rescue
            # nop
          end
        end
        result
      end

      def area(node)
        area(node)
      end

      def workgroup(node)
        workgroup(node)
      end

      def keyword(node)
        keyword(node)
      end

      def inline_anchor(node)
        inline_anchor(node)
      end

      def inline_indexterm(node)
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible
          item = set_header_attribute "item", node.text
          "#{node.text}<iref#{item}/>"
        else
          item = set_header_attribute "item", terms[0]
          item = set_header_attribute "subitem", (terms.size > 1 ? terms[1] : nil)
          terms = node.attr "terms"
          "<iref#{item}#{subitem}/>"
          "<iref#{item}#{subitem}/>"
          warn %(asciidoctor: WARNING: only primary and secondary index terms supported: #{terms.join(': ')}") if terms.size > 2
        end
      end

      def inline_break(node)
        %(#{node.text}<vspace/>)
      end

      def inline_quoted(node)
        case node.type
        when :emphasis
          %(<spanx style="emph">#{node.text}</spanx>)
        when :strong
          %(<spanx style="strong">#{node.text}</spanx>)
        when :monospaced
          %(<spanx style="verb">#{node.text}</spanx>)
        when :double
          "\"#{node.text}\""
        when :single
          "'#{node.text}'"
        when :superscript
          "^#{node.text}^"
        when :subscript
          "_#{node.text}_"
        else
          node.text
        end
      end

      def literal(node)
        # [[id]]
        # .Name
        # [align=left|center|right,alt=alt_text,type] (optional)
        # ....
        #   literal
        # ....
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        type = get_header_attribute node, "type"
        name = set_header_attribute "name", node.title

        result << "<artwork#{id}#{align}#{name}#{type}#{alt}>"
        node.lines.each do |line|
          result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
        end
        result << "</artwork>"

        result << "</figure>" if node.parent.context != :example
        result
      end

      def stem(node)
        literal node
      end

      def paragraph(node)
        #    [[id]]
        #    Text
        result = []
        if (node.parent.context == :preamble) && (not $seen_abstract)
          result << "<abstract>"
          $seen_abstract = true
        end
        id = set_header_attribute "anchor", node.id
        result << "<t#{id}>#{node.content}</t>"
        result
      end

      def open(node)
        paragraph node
      end

      def admonition(node)
        #    = Title
        #    Author
        #    :HEADER
        #
        #    ABSTRACT
        #
        # NOTE: note
        #
        #    [NOTE]
        #    .Title (in preamble)
        #    ====
        #      Content
        #    ====
        #
        #      [NOTE] (in preamble)
        #      [NOTE,source=name] (in body)
        #    .Title
        #    ====
        #      Content
        #    ====
        #
        # admonitions within preamble are notes. Elsewhere, they are comments.
        result = []
        if node.parent.context == :preamble
          if $seen_abstract
            result << "</abstract>"
            $seen_abstract = false
          end
          title = set_header_attribute "title", node.title
          result << "<note#{title}>"
          result << (paragraph1 node)
          result << "</note>"
        else
          id = set_header_attribute "anchor", node.id
          source = get_header_attribute node, "source"
          if node.parent.context !~ /table|example|paragraph/
            result << "<t>"
          end
          result << "<cref#{id}#{source}>"
          result << node.content
          result << "</cref>"
          if node.parent.context !~ /table|example|paragraph/
            result << "</t>"
          end
        end
        result
      end

      # ulist repurposed as reference list
      def reflist(node)
        # ++++
        # <xml>
        # ++++
        # TODO push through references as undigested XML
        result = []
        node.lines.each do |item|
          # we expect the biblio anchor to be right at the start of the reference
          target = get_header_attribute node, "target"
          # undo XML substitution
          ref = item.gsub(/\&lt;/, "<").gsub(/\&gt;/, ">")
          # result << "<reference>#{ref}</reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference#{target} anchor=\"\\1\">")
          result << ref
        end
        result
      end

      def section(node)
        # [[id]]
        # == title
        # Content
        #
        # [bibliography]
        # == Normative|Informative References
        # * [[[ref1]]] Ref [must provide references as list]
        # * [[[ref2]]] Ref
        #
        result = []
        if node.attr("style") == "bibliography"
          $xreftext = {}
          $processing_reflist = true
          title = set_header_attribute "title", node.title
          result << "<references#{title}>"
          # require that references be given in a ulist
          node.blocks.each { |b| result << reflist(b) }
          result << "</references>"
          result = result.unshift("</middle><back>") unless $seen_back_matter
          $processing_reflist = false
          $seen_back_matter = true
        else
          id = set_header_attribute "anchor", node.id
          if node.attr("style") == "appendix"
            result << "</middle><back>" unless $seen_back_matter
            $seen_back_matter = true
          end
          title = set_header_attribute "title", node.title
          result << "<section#{id}#{title}>"
          result << node.content
          result << "</section>"
        end
        result
      end

      def table(node)
        # [[id]]
        # .Title
        # [suppress-title,align,style]
        # |===
        # |col | col
        # |===
        has_body = false
        result = []
        id = set_header_attribute "anchor", node.id
        title = set_header_attribute "title", node.title
        suppresstitle = get_header_attribute node, "suppress-title"
        align = get_header_attribute node, "align"
        style = get_header_attribute node, "style"
        styleval = case node.attr "grid"
                   when "all"
                     "all"
                   when "rows"
                     "none" # not supported
                   when "cols"
                     "full"
                   when "none"
                     "none"
                   else
                     "all"
                   end
        style = set_header_attribute "style", styleval
        result << %(<texttable#{id}#{title}#{suppresstitle}#{align}#{style}>)
        # preamble, postamble elements not supported

        [:head].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
          has_body = true if tblsec == :body
          # id = set_header_attribute "anchor", tblsec.id
          # not supported
          if node.rows[tblsec].size > 1
            warn "asciidoctor: WARNING: RFC XML v2 tables only support a single header row"
          end
          widths = []
          node.columns.each do |col|
            widths << col.attr("colpcwidth")
          end
          node.rows[tblsec].each do |row|
            rowlength = 0
            result1 = []
            row.each_with_index do |cell, i|
              id = set_header_attribute "anchor", cell.id
              align = set_header_attribute("align", cell.attr("halign"))
              width = if !node.option?("autowidth") && (i < widths.size)
                        set_header_attribute("width", "#{widths[i]}%")
                      end
              entry_start = %(<ttcol#{id}#{align}#{width}>)
              cell_content = cell.text
              rowlength += cell_content.size
              result1 << %(#{entry_start}#{cell_content}</ttcol>)
            end
            result << result1
            if rowlength > 72
              warn "asciidoctor: WARNING: header row of table is longer than 72 ascii characters:\n#{result1}"
            end
          end
        end

        [:body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
          has_body = true if tblsec == :body
          # id = set_header_attribute "anchor", tblsec.id
          # not supported
          node.rows[tblsec].each_with_index do |row, i|
            rowlength = 0
            result1 = []
            row.each do |cell|
              cell_content = cell.text
              rowlength += cell_content.size
              result1 << %(<c>#{cell_content}</c>)
            end
            result << result1
            if rowlength > 72
              warn "asciidoctor: WARNING: row #{i} of table is longer than 72 ascii characters:\n#{result1}"
            end
          end
        end
        result << "</texttable>"

        warn "asciidoctor: WARNING: tables must have at least one body row" unless has_body
        result
      end

      def ulist(node)
        #    * A
        #    * B
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        style = set_header_attribute "style", "symbols"
        result << "<list#{style}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<t#{id}>#{item.text}"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end

      (OLIST_TYPES = {
        arabic:     "numbers",
        # decimal:    "1", # not supported
        loweralpha: "format %c",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "format %i",
        upperalpha: "format %C",
        upperroman: "format %I",
      }).default = "numbers"

      def olist(node)
        #    [start=n] (optional)
        #    . A
        #    . B
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        counter = set_header_attribute "counter", node.attr("start")
        # TODO did I understand spec of @counter correctly?
        style = set_header_attribute "style", OLIST_TYPES[node.style]
        result << "<list#{counter}#{style}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<t#{id}>#{item.text}"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end

      def dlist(node)
        #    [hangIndent=n] (optional)
        #    A:: B
        #    C:: D
        result = []
        result << "<t>" if node.parent.context !~ /paragraph|list_item/
        hangIndent = get_header_attribute node, "hangIndent"
        style = set_header_attribute "style", "hanging"
        result << "<list#{hangIndent}#{style}>"
        node.items.each do |terms, dd|
          hangtext = []
          id = nil
          [*terms].each do |dt|
            # we collapse multiple potential ids into the last seen
            id = set_header_attribute "anchor", dt.id unless dt.id.nil?
            hangtext << dt.text
          end
          unless dd.id.nil?
            id = set_header_attribute "anchor", dd.id
          end
          hangText = set_header_attribute "hangText", hangtext.join(", ")
          if dd.blocks?
            result << "<t#{id}#{hangText}>#{dd.text}"
            result << dd.content
            result << "</t>"
          else
            result << "<t#{id}#{hangText}>#{dd.text}</t>"
          end
        end
        result << "</list>"
        result << "</t>" if node.parent.context !~ /paragraph|list_item/
        result
      end

      def preamble(node)
        #    = Title
        #    Author
        #    :HEADER
        #
        #    ABSTRACT
        #
        # NOTE: note
        #
        #    (boilerplate is ignored)
        result = []
        $seen_abstract = false
        result << node.content
        if $seen_abstract
          result << "</abstract>"
        end
        result << "</front><middle>"
        result
      end

      def example(node)
        # [[id]]
        # .Title
        # [align,alt,suppress-title]
        # ====
        # Example
        # ====
        result = []
        id = set_header_attribute "anchor", node.id
        alt = set_header_attribute "alt", node.alt
        title = set_header_attribute "title", node.title
        suppresstitle = get_header_attribute node, "suppress-title"
        align = get_header_attribute node, "align"
        result << "<figure#{id}#{align}#{alt}#{title}#{suppresstitle}>"
        seen_artwork = false
        # TODO iref
        result.blocks.each do |b|
          if (b == :listing) || (b == :image) || (b == :literal)
            result << node.content
            seen_artwork = true
          else
            result << seen_artwork ? "<preamble>" : "<postamble>"
            result << node.content
            result << seen_artwork ? "</preamble>" : "</postamble>"
          end
        end
        result << "</figure>"
        result
      end

      def inline_image(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        align = get_header_attribute node, "align"
        alt = get_header_attribute node, "alt"
        link = (node.image_uri node.target)
        src = set_header_attribute node, "src", link
        type = set_header_attribute node, "type", link =~ /\.svg$/ ? "svg" : "binary-art"
        result << "<artwork#{align}#{alt}#{type}#{src}/>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      def image(node)
        # [[id]]
        # .Name
        # [link=xxx,align=left|center|right,alt=alt_text,type]
        # image::filename[]
        # ignoring width, height attributes
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        link = (node.image_uri node.target)
        src = set_header_attribute node, "src", link
        type = get_header_attribute node, "type"
        name = get_header_attribute node, "name"
        result << "<artwork#{id}#{name}#{align}#{alt}#{type}#{src}/>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      def listing(node)
=begin
.name
[source,type,src=uri] (src is mutually exclusive with listing content) (v3)
[source,type,src=uri,align,alt] (src is mutually exclusive with listing content) (v2)
----
code
----
=end
        result = []
        result << "<figure>" if node.parent.context != :example
        align = set_header_attribute "align", node.title
        alt = set_header_attribute "alt", node.alt
        tag = "artwork"
        id = set_header_attribute "anchor", node.id
        name = set_header_attribute "name", node.title
        type = set_header_attribute "type", node.attr("language")
        src = set_header_attribute "src", node.attr("src")
        result << "<#{tag}#{id}#{align}#{name}#{type}#{src}#{alt}>"
        if src.nil?
          node.lines.each do |line|
            result << line.gsub(/\&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
          end
        end
        result << "</#{tag}>"
        result << "</figure>" if node.parent.context != :example
        result
      end
    end
  end
end
