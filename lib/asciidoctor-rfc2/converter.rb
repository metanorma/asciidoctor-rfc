require "Date"
require "pp"

module Asciidoctor
  module Rfc2
    # A {Converter} implementation that generates RFC XML 2 output, a format used to 
    # format RFC proposals (https://tools.ietf.org/html/rfc7749)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md

    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      register_for 'rfc2'

      $seen_back_matter = false
      $xreftext = {}

      def initialize backend, opts
        super
        #basebackend 'html'
        outfilesuffix '.xml'
      end

      def convert node, transform = nil, opts = {}
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def content node
        node.content
      end

      def skip node, name = nil
        warn %(asciidoctor: WARNING: converter missing for #{name || node.node_name} node in RFC backend)
        nil
      end

      alias :pass :content
      alias :embedded :content
      alias :sidebar :content
      alias :audio :skip
      alias :colist :skip
      alias :floating_title :skip
      alias :open :content
      alias :page_break :skip
      alias :thematic_break :skip
      alias :video :skip
      alias :inline_button :skip
      alias :inline_kbd :skip
      alias :inline_menu :skip
      alias :verse :content
      alias :quote :content

      def get_header_attribute node, attr, default = nil
        if (node.attr? attr) 
          %( #{attr}="#{node.attr attr}") 
        elsif default.nil? 
          nil 
        else 
          %( #{attr}="#{default}")
        end
      end

      def set_header_attribute attr, val
        if val.nil? 
          nil 
        else
          %( #{attr}="#{val}")
        end
      end

      def document_ns_attributes doc
        #' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def document node
=begin
=Title
Author
:category
:consensus
:docName
:number

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

=end
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        category = get_header_attribute node, "category"
        consensus = get_header_attribute node, "consensus"
        docName = get_header_attribute node, "docName"
        number = get_header_attribute node, "number"
        warn "asciidoctor: WARNING: both docName and number attributes present" unless number.nil? or docName.nil?
        ipr = get_header_attribute node, "ipr"
        iprExtract = get_header_attribute node, "indexInclude"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        seriesNo = get_header_attribute node, "seriesNo"
        submissionType = get_header_attribute node, "submisionType", "IETF"
        xmllang = get_header_attribute node, "xml:lang"

        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{category}
        #{consensus}#{submissionType}#{iprExtract}#{docName}#{number}#{seriesNo}#{xmllang}>)
        result << (front node)
        result << "</front><middle1>"
        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        if result.any? { |e| e == "</front><middle>" } and result.any? { |e| e == "</front><middle1>" }
          result = result.reject { |e| e == "</front><middle1>" }
        else
          result = result.map { |e| e == "</front><middle1>" ? "</front><middle>" : e }
        end

        result * "\n"
      end

      def front node
=begin
= Title
Author
:METADATA
=end
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

      def author node
=begin
= Title
Author;Author_2;Author_3
:fullname
:lastname
:organization
:email
:fullname_2
:lastname_2
:organization_2
:email_2
:fullname_3
:lastname_3
:organization_3
:email_3
=end
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

      def author1 node, suffix
=begin
= Title
Author (contains author firstname lastname middlename authorinitials email: Firstname Middlename Lastname <Email>)
:fullname
:lastname
:organization
:organization_abbrev
:email
:role
:fax
:uri
:phone
:street (lines broken up by "\ ")
:city
:region
:country
:code
=end
        result = []
        authorname = set_header_attribute "fullname", node.attr("author#{suffix}")
        surname = set_header_attribute "surname", node.attr("lastname#{suffix}")
        initials = set_header_attribute "initials", node.attr("firstname#{suffix}")[0]
        role = set_header_attribute "role", node.attr("role#{suffix}")
        organization_abbrev = node.attr("organization_abbrev#{suffix}")
        organization = node.attr("organization#{suffix}")
        street = node.attr("street#{suffix}")
        city = node.attr("city#{suffix}")
        region = node.attr("region#{suffix}")
        country = node.attr("country#{suffix}")
        code = node.attr("code#{suffix}")
        phone = node.attr("phone#{suffix}")
        email = node.attr("email#{suffix}")
        facsimile = node.attr("fax#{suffix}")
        uri = node.attr("uri#{suffix}")

        result << "<author#{authorname}#{initials}#{surname}#{role}>"
        abbrev = set_header_attribute "abbrev", organization_abbrev
        result << "<organization#{abbrev}>#{organization}</organization>" unless organization.nil?

        if not email.nil? or not facsimile.nil? or not uri.nil? or not phone.nil? or 
          not street.nil?
          result << "<address>"
          if not street.nil?
            result << "<postal>"
            street.split("\\ ").each { |p| result << "<street>#{p}</street>" } unless street.nil?
            result << "<city>#{city}</city>" unless city.nil?
            result << "<region>#{region}</region>" unless region.nil?
            result << "<code>#{code}</code>" unless code.nil?
            result << "<country>#{country}</country>" unless country.nil?
            result << "</postal>"
          end
          result << "<phone>#{phone}</phone>" unless phone.nil?
          result << "<facsimile>#{facsimile}</facsimile>" unless facsimile.nil?
          result << "<email>#{email}</email>"  unless email.nil?
          result << "<uri>#{uri}</uri>"  unless uri.nil?
          result << "</address>"
        end
        result << "</author>"
        result
      end

      def date node
=begin
= Title
Author
:revdate or :date
=end
        result = []
        revdate = node.attr("revdate")
        revdate = node.attr("date") if revdate.nil?
        unless revdate.nil?
          begin
            revdate.gsub!(/T.*$/, "")
            d = Date.iso8601 revdate
            day = set_header_attribute "day", d.day
            month = set_header_attribute "month", d.month
            year = set_header_attribute "year", d.year
            result << "<date#{day}#{month}#{year}/>"
          rescue
            # nop
          end
        end
        result
      end

      def area node
=begin
= Title
Author
:area x, y
=end
        result = []
        area = node.attr("area")
        unless area.nil?
          area.split(/, ?/).each { |a| result << "<area>#{a}</area>" }
        end
        result
      end

      def workgroup node
=begin
= Title
Author
:workgroup x, y
=end
        result = []
        workgroup = node.attr("workgroup")
        unless workgroup.nil?
          workgroup.split(/, ?/).each { |a| result << "<workgroup>#{a}</workgroup>" }
        end
        result
      end

      def keyword node
=begin
= Title
Author
:keyword x, y
=end
        result = []
        keyword = node.attr("keyword")
        unless keyword.nil?
          keyword.split(/, ?/).each { |a| result << "<keyword>#{a}</keyword>" }
        end
        result
      end

      def inline_anchor node
        case node.type
        when :xref
          # format attribute not supported
          unless (text = node.text) || (text = node.attributes['path'])
            refid = node.attributes['refid']
            text = %([#{refid}])
          end
          %(<xref target="#{node.target}">#{text}</xref>)
        when :link
          %(<eref target="#{node.target}">#{node.text}</eref>)
        when :bibref
          unless node.xreftext.nil?
            x = node.xreftext.gsub(/^\[(.+)\]$/, "\\1")
            if node.id != x
              $xreftext[node.id] = x
            end
          end
          # NOTE technically node.text should be node.reftext, but subs have already been applied to text
          %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
        when :ref
          warn %(asciidoctor: WARNING: anchor "#{node.id}" is not in a place where XML RFC will recognise it as an anchor attribute)
        else
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
      end

      def inline_indexterm node
        # supports only primary and secondary terms
        # primary attribute (highlighted major entry) not supported
        if node.type == :visible 
          item = set_header_attribute "item", node.text
          "#{node.text}<iref#{item}/>"
        else
          item = set_header_attribute "item", terms[0]
          item = set_header_attribute "subitem", (terms.size > 1 ? terms[1] : nil )
          terms = node.attr "terms"
          "#{node.text}<iref#{item}#{subitem}/>"
        end
      end

      def inline_break node
        %(#{node.text}<vspace/>)
      end

      def inline_quoted node
        case node.type
        when :emphasis
          %(<spanx style="emph">#{node.text}</em>)
        when :strong
          %(<spanx style="strong">#{node.text}</strong>)
        when :monospaced
          %(<spanx style="verb">#{node.text}</tt>)
        when :double
          "\"#{node.text}\""
        when :single
          "'#{node.text}'"
        else
          node.text
        end
      end

      def paragraph node
=begin
   [[id]]
   Text
=end
        result = []
        if node.parent.context == :preamble
          result << "<abstract>"
          result << node.content
          result << "</abstract>"
        else
          id = set_header_attribute "anchor", node.id
          result << "<t#{id}>#{node.content}</t>"
        end
        result
      end

      def paragraph1 node
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          id = set_header_attribute "anchor", node.id
          result << "<t#{id}>"
          result << result1
          result << "</t>"
        end
        result
      end

      def admonition node
=begin
   = Title
   Author
   :HEADER

   ABSTRACT

NOTE: note

   [NOTE]
   .Title (in preamble)
   ====
     Content
   ====

     [NOTE] (in preamble)
     [NOTE,source=name] (in body)
   .Title
   ====
     Content
   ====

=end
        # admonitions within preamble are notes. Elsewhere, they are comments.
        result = []
        if node.parent.context == :preamble
          title = set_header_attribute node, "title", node.title
          result << "<note#{title}>"
          result << (paragraph1 node)
          result << "</note>"
        else
          id = set_header_attribute "anchor", node.id
          source = get_header_attribute node, "source"
          result << "<cref#{id}#{source}>"
          result << node.content
          result << "</cref>"
        end
        result
      end

      # ulist repurposed as reference list
      def reflist node
=begin
   * [[[ref1]]] A
   [target=uri] (optional)
   * [[[ref2]]] B
=end
        # TODO push through references as undigested XML
        result = []
        node.items.each do |item|
          # we expect the biblio anchor to be right at the start of the reference
          target = get_header_attribute node, "target"
          result << "<reference>#{item.text}</refcontent></reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference#{target} anchor=\"\\1\"><refcontent>")
        end
        result
      end

      def section node
=begin
[[id]]
[removeInRFC=true,toc=include|exclude|default] (optional)
== title
Content

[[id]]
[bibliography]
== Normative|Informative References
* [[[ref1]]] Ref [must provide references as list]
* [[[ref2]]] Ref

=end
        result = []
        if node.attr("style") == "bibliography"
          $xreftext = {}
          $processing_reflist = true
          id = set_header_attribute "anchor", node.id
          title = set_header_attribute "title", node.title
          result << "<references#{id}#{title}>"
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

      def listing node
=begin
.name
[source,type,src=uri,align,alt] (src is mutually exclusive with listing content)
----
code
----
=end
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = set_header_attribute "align", node.title
        name = set_header_attribute "name", node.title
        type = set_header_attribute "type", node.attr("language")
        src = set_header_attribute "src", node.attr("src")
        alt = set_header_attribute "alt", node.alt

        result << "<artwork#{id}#{align}#{name}#{type}#{src}#{alt}>"
        if src.nil?
          result << node.text.gsub(/\&/,"&amp;").gsub(/</,"&lt;").gsub(/>/,"&gt;")
        end
        result << "</artwork>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      def ulist node
=begin
   * A
   * B
=end
        result = []
        style = set_header_attribute "style", "symbols"
        result << "<list#{style}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<t#{id}>"
            result << item.content 
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</t>"
          end
        end
        result << "</t>"
        result
      end

      (OLIST_TYPES = {
        arabic:     "numbers",
        # decimal:    "1", # not supported
        loweralpha: "format %c",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "format %i",
        upperalpha: "format %C",
        upperroman: "format %I"
      }).default = "numbers"

      def olist node
=begin
   [start=n] (optional)
   . A
   . B
=end
        result = []
        counter = set_header_attribute node, "counter", node.attr("start")
        # TODO did I understand spec of @counter correctly?
        type = set_header_attribute node, "type", OLIST_TYPES[node.style]
        result << "<list#{counter}#{style}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<t#{id}>"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}>#{item.text}</li>"
          end
        end
        result << "</list>"
        result
      end

      def dlist node
=begin
   [hangIndent=n] (optional)
   A:: B
   C:: D
=end
        result = []
        hangIndent = get_header_attribute  node, "hangIndent"
        style = set_header_attribute "style", "hanging"
        result << "<list#{hangIndent}#{style}>"
        node.items.each do |terms, dd|
          hangtext =[]
          id = nil
          [*terms].each do |dt|
            # we collapse multiple potential ids into the last seen
            id = set_header_attribute "anchor", dt.id unless dt.id.nil?
            hangtext << dt.text
          end
          unless item.id.nil?
            id = set_header_attribute "anchor", item.id
            hangText = set_header_attribute "hangText", hangText.join(", ")
          end
          if item.blocks?
            result << "<t#{id}#{hangText}>"
            result << item.content
            result << "</t>"
          else
            result << "<t#{id}#{hangText}>#{item.text}</t>"
          end
        end
        result << "</list>"
        result
      end

      def preamble node
=begin
   = Title
   Author
   :HEADER

   ABSTRACT

NOTE: note

   (boilerplate is ignored)
=end
        result = []
        result << node.content
        result << "</front><middle>"
        result
      end
    end

    def table node
=begin
[[id]]
.Title
[suppress-title,align,style]
|===
|col | col
|===
=end
      has_body = false
      result = []
      id = set_header_attribute "anchor", node.id
      title = set_header_attribute "title", node.title
      suppresstitle = get_header_attribute node, "suppress-title"
      align = get_header_attribute node, "align"
      style = get_header_attribute node, "style"
      result << %(<table#{id}#{title}#{suppresstitle}#{align}#{style}">)
      # preamble, postamble elements not supported

      [:head].select {|tblsec| !node.rows[tblsec].empty? }.each do |tblsec|
        has_body = true if tblsec == :body
        # id = set_header_attribute "anchor", tblsec.id
        # not supported
        if node.rows[tblsec] > 1
          warn "asciidoctor: WARNING: RFC XML v2 tables only support a single header row"
        end
        widths = []
        node.columns.each do |col|
          widths << col.attr("colpcwidth")
        end
      end
      node.rows[tblsec].each do |row|
        row.each_with_index do |cell, i|
          id = set_header_attribute "anchor", row.id
          align = set_header_attribute("align", cell.attr("halign"))
          if   !node.option? "autowidth" and  i < widths.size
            width =  set_header_attribute("width", widths[i])
          else
            width = nil
          end
          entry_start = %(<ttcol#{id}#{align}#{width}>)
          cell_content = if cell.blocks?
                           cell.content
                         else
                           cell.text
                         end
          result << %(#{entry_start}#{cell_content}</ttcol>)
        end
      end

      [:body,:foot].select {|tblsec| !node.rows[tblsec].empty? }.each do |tblsec|
        has_body = true if tblsec == :body
        # id = set_header_attribute "anchor", tblsec.id
        # not supported
        node.rows[tblsec].each do |row|
          row.each do |cell|
            cell_content = if cell.blocks?
                             cell.content
                           else
                             cell.text
                           end
            result << %(<c>#{cell_content}</c>)
          end
        end
      end
      result << "</table>"

      warn "asciidoctor: WARNING: tables must have at least one body row" unless has_body
      result 
    end

    def example node
=begin
[[id]]
.Title
[align,alt,suppress-title]
====
Example
====
=end
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
        if b == :listing or b == :image or b == :literal
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

    def literal node
=begin
[[id]]
[align=left|center|right,alt=alt_text,name,type] (optional)
....
literal
....
=end
      result = []
      result << "<figure>" if node.parent.context != :example
      id = set_header_attribute "anchor", node.id
      align = get_header_attribute node, "align"
      alt = set_header_attribute "alt", node.alt
      type = get_header_attribute node, "type"
      name = set_header_attribute "name", node.title

      result << "<artwork#{id}#{align}#{name}#{type}#{alt}>"
      if src.nil?
        result << node.text.gsub(/\&/,"&amp;").gsub(/</,"&lt;").gsub(/>/,"&gt;")
      end
      result << "</artwork>"

      result << "</figure>" if node.parent.context != :example
      result
    end

    def inline_image node
      result = []
      result << "<figure>" if node.parent.context != :example
      align = get_header_attribute node, "align"
      alt = get_header_attribute node, "alt"
      link =  (node.image_uri node.target)
      src = set_header_attribute node, "src", link
      result << "<artwork#{align}#{alt}#{src}/>"
      result << "</figure>" if node.parent.context != :example
      result
    end

    def image node
=begin
[[id]]
.Name
[link=xxx,align=left|center|right,alt=alt_text,type]
image::filename[]
=end
      # ignoring width, height attributes
      result = []
      result << "<figure>" if node.parent.context != :example
      id = set_header_attribute "anchor", node.id
      align = get_header_attribute node, "align"
      alt = set_header_attribute "alt", node.alt
      link =  (node.image_uri node.target)
      src = set_header_attribute node, "src", link
      type = get_header_attribute node, "type"
      name = get_header_attribute node, "name"
      result << "<artwork#{id}#{name}#{align}#{alt}#{type}#{src}/>"
      result << "</figure>" if node.parent.context != :example
      result
    end

    def stem node
      literal node
    end

  end
end
