require_relative "../common"

module Asciidoctor
  module RFC::V3
    # A {Converter} implementation that generates RFC XML output, a format used to 
    # format RFC proposals (https://tools.ietf.org/html/rfc7991)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md

    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      register_for 'rfc3'

      $seen_back_matter = false
      $seen_abstract = false
      $xreftext = {}

      def initialize(backend, opts)
        super
        # basebackend 'html'
        outfilesuffix '.xml'
      end

      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def content node
        Asciidoctor::RFC::Common.content node
      end

      def skip node, name = nil
        Asciidoctor::RFC::Common.skip node, name
      end

      alias :pass :content
      alias :embedded :content
      alias :audio :skip
      alias :colist :skip
      alias :floating_title :skip
      alias :page_break :skip
      alias :thematic_break :skip
      alias :video :skip
      alias :inline_button :skip
      alias :inline_kbd :skip
      alias :inline_menu :skip
      alias :inline_callout :content

      def get_header_attribute node, attr, default = nil
        if (node.attr? dash(attr)) 
          %( #{attr}="#{node.attr dash(attr)}") 
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
        ipr = get_header_attribute node, "ipr"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        indexInclude = get_header_attribute node, "indexInclude"
        iprExtract = get_header_attribute node, "iprExtract"
        sortRefs = get_header_attribute node, "sortRefs"
        symRefs = get_header_attribute node, "symRefs"
        tocInclude = get_header_attribute node, "tocInclude"
        submissionType = get_header_attribute node, "submissionType", "IETF"
        t = Time.now.getutc
        preptime = set_header_attribute "preptime", 
          sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", t.year, t.month, t.day, t.hour, t.min, t.sec)
        version = set_header_attribute "version", "3"
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}
        #{version}#{submissionType}#{indexInclude}#{iprExtract}#{sortRefs}#{symRefs}#{tocInclude}>)
        result << (link node)
        result << (front node)
        result << "</front><middle1>"
        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        result = result.flatten
        if result.any? { |e| e =~ /<\/front><middle>/ } and result.any? { |e| e =~ /<\/front><middle1>/ }
          result = result.reject { |e| e =~ /<\/front><middle1>/ }
        else
          result = result.map { |e| e =~ /<\/front><middle1>/ ? "</front><middle>" : e }
        end

        result * "\n"
      end

      def link node
=begin
= Title
Author
:link href,href rel
=end
        result = []
        links = node.attr "link"
        return result if links.nil?
        links.split(/,/).each do |l|
          m = /^(\S+)\s+(\S+)$/.match(l)
          if m.nil?  
            href = set_header_attribute "href", l
            result << "<link#{href}/>"
          else
            href = set_header_attribute "href", m[1]
            rel = set_header_attribute "rel", m[2]
            result << "<link#{href}#{rel}/>"
          end
        end 
        result
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
        result << (series_info node)
        result << (author node)
        result << (date node)
        result << (area node)
        result << (workgroup node)
        result << (keyword node)
      end

      def series_info node
=begin
= Title
Author
:name rfc-* || Internet-Draft-Name
:status (of this document)
:intendedstatus (of internet draft once published as RFC)
:rfcstatus (of RFC: full-standard|bcp|fyi number or info|exp|historic)
:stream
=end
        result = []
        status = get_header_attribute node, "status"
        stream = get_header_attribute node, "stream", "IETF"
        name = node.attr "docname"
        rfc = true
        unless name.nil? and not name.empty?
          if name =~ /^rfc-?/i
            name = name.gsub(/^rfc-?/i, "")
            nameattr = set_header_attribute "name", "RFC"
          else
            nameattr = set_header_attribute "name", "Internet-Draft"
            rfc = false
          end
          name = name.gsub(/\.[^\/]+$/, "")
          value = set_header_attribute "value", name
          status = get_header_attribute node, "status"
          result << "<seriesInfo#{nameattr}#{status}#{stream}#{value}/>"

          intendedstatus = node.attr("intendedstatus")
          unless intendedstatus.nil? and not rfc
            status = set_header_attribute "status", intendedstatus
            nameattr = set_header_attribute "name", ""
            result << "<seriesInfo#{nameattr}#{status}#{value}/>"
          end

          rfcstatus = node.attr("rfcstatus")
          unless rfcstatus.nil? and rfc
            m = /^(\S+) (\d+)$/.match(rfcstatus)
            if m.nil?  
              nameattr = set_header_attribute "name", ""
              status = set_header_attribute "status", rfcstatus
              value = set_header_attribute "value", ""
              result << "<seriesInfo#{nameattr}#{status}#{value}/>"
            else
              rfcstatus1 = m[1]
              rfcstatus2 = m[2]
              nameattr = set_header_attribute "name", ""
              status = set_header_attribute "status", rfcstatus1
              value = set_header_attribute "value", rfcstatus2
              result << "<seriesInfo#{nameattr}#{status}#{value}/>"
            end
          end
        end
        result
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
:forename_initials (excludes surname, unlike Asciidoc "initials" attribute)
:organization
:email
:role
:fax
:uri
:phone
:postalLine (mutually exclusive with street city etc) (lines broken up by "\ ")
:street
:city
:region
:country
:code
=end
        result = []
        result << Asciidoctor::RFC::Common.authorname(node, suffix)
        result << Asciidoctor::RFC::Common.organization(node, suffix, 3)
        result << Asciidoctor::RFC::Common.address(node, suffix, 3)
        result << "</author>"
        result

      end

      def date node
        Asciidoctor::RFC::Common.date(node, 3)
      end

      def area node
        Asciidoctor::RFC::Common.area(node)
      end

      def workgroup node
        Asciidoctor::RFC::Common.workgroup(node)
      end

      def keyword node
        Asciidoctor::RFC::Common.keyword(node)
      end

      def inline_anchor(node)
        Asciidoctor::RFC::Common.inline_anchor(node)
      end

      def inline_indexterm node
        Asciidoctor::RFC::Common.inline_indexterm(node)
      end

      def inline_break node
        %(#{node.text}<br/>)
      end

      def inline_quoted node
        case node.type
        when :emphasis
          "<em>#{node.text}</em>"
        when :strong
          "<strong>#{node.text}</strong>"
        when :monospaced
          "<tt>#{node.text}</tt>"
        when :double
          "\"#{node.text}\""
        when :single
          "'#{node.text}'"
        when :superscript
          "<sup>#{node.text}</sup>"
        when :subscript
          "<sub>#{node.text}</sub>"
        else
=begin
[bcp14]#MUST NOT#
=end
          if node.role == "bcp14"
            "<bcp14>#{node.text}</bcp14>"
          else
            node.text
          end
        end
      end

      def literal node
=begin
[[id]]
[align=left|center|right,alt=alt_text] (optional)
....
  literal
....
=end
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        type = set_header_attribute "type", "ascii-art"
        result << "<artwork#{id}#{align}#{alt}#{type}>"
        node.lines.each do |line|
          result << line.gsub(/\&/,"&amp;").gsub(/</,"&lt;").gsub(/>/,"&gt;")
        end
        result << "</artwork>"
        result << "</figure>" if node.parent.context != :example
        result
      end

      def stem node
        literal node
      end


      def paragraph node
=begin
  [[id]]
  [keepWithNext=true,keepWithPrevious=true] (optional)
  Text
=end
        result = []
        if node.parent.context == :preamble and not $seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end
        id = set_header_attribute "anchor", node.id
        keepWithNext = get_header_attribute node, "keepWithNext"
        keepWithPrevious = get_header_attribute node, "keepWithPrevious"
        result << "<t#{id}#{keepWithNext}#{keepWithPrevious}>#{node.content}</t>"
        result
      end

      def open node
        paragraph node
      end

      def quote node
=begin
[[id]]
[quote, attribution, citation info] # citation info limited to URL
Text
=end
        result = []
        id = set_header_attribute "anchor", node.id
        quotedFrom = set_header_attribute "quotedFrom", node.attr("attribution")
        citationInfo = node.attr "citetitle"
        if !citationInfo.nil? && citationInfo =~  URI::DEFAULT_PARSER.make_regexp
          cite = set_header_attribute "cite", citationInfo
        end
        result << "<blockquote#{id}#{quotedFrom}#{cite}>"
        result << node.content
        result << "</blockquote>"
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

    [NOTE,removeInRFC=true] (in preamble)
    [NOTE,display=true|false,source=name] (in body)
  .Title
  ====
    Content
  ====

=end
        # admonitions within preamble are notes. Elsewhere, they are comments.
        result = []
        if node.parent.context == :preamble
          if $seen_abstract
            $seen_abstract = false
            result << "</abstract>"
          end
          removeInRFC = get_header_attribute node, "removeInRFC"
          result << "<note#{removeInRFC}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          result << (Asciidoctor::RFC::Common.paragraph1 node)
          result << "</note>"
        else
          id = set_header_attribute "anchor", node.id
          display = get_header_attribute node, "display"
          source = get_header_attribute node, "source"
          result << "<cref#{id}#{display}#{source}>"
          result << node.content
          result << "</cref>"
        end
        result
      end

      # ulist repurposed as reference list
      def reflist node
=begin
  * [[[ref1]]] A
  [quoteTitle=false,target=uri,annotation=x] (optional)
  * [[[ref2]]] B
  * [[[ref3]]] (Referencegroup: no content)
    * [[[ref4]]] C
    * [[[ref4]]] D
=end
        # TODO reference/front not supported
        result = []
        node.items.each do |item|
          # we expect the biblio anchor to be right at the start of the reference
          if item.blocks?
            # we expect any list to be embedded, and only one level of embedding
            # we expect no content in the referencegroup line other than the bibliographic anchor
            result << "<referencegroup>#{item.text}".gsub(/<referencegroup>\s*\[?<bibanchor="([^"]+)">\]?.*$/, "<referencegroup anchor=\"\\1\">")
            item.blocks.each { |b| result << reflist(b) }
            result << "</referencegroup>"
          else
            quoteTitle = get_header_attribute node, "quoteTitle"
            target = get_header_attribute node, "target"
            annotation = get_header_attribute node, "annotation"
            # Bug: [[[x]]] within embedded list is processed as [<bibref>]
            result << "<reference>#{item.text}</refcontent></reference>".gsub(/<reference>\s*\[?<bibanchor="([^"]+)">\]?\s*/, "<reference#{quoteTitle}#{target}#{annotation} anchor=\"\\1\"><refcontent>")
          end
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
          result << "<references#{id}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          # require that references be given in a ulist
          node.blocks.each { |b| result << reflist(b) }
          result << "</references>"
          unless $xreftext.empty?
            result.unshift( $xreftext.keys.map { | k | %(<displayreference target="#{k}" to="#{$xreftext[k]}"/>) })
          end
          result = result.unshift("</middle><back>") unless $seen_back_matter
          $processing_reflist = false
          $seen_back_matter = true
        else
          id = set_header_attribute "anchor", node.id
          removeInRFC = get_header_attribute node, "removeInRFC"
          toc = get_header_attribute node, "toc"
          numbered = set_header_attribute "numbered", node.attr?("sectnums")
          if node.attr("style") == "appendix"
            result << "</middle><back>" unless $seen_back_matter
            $seen_back_matter = true
          end
          result << "<section#{id}#{removeInRFC}#{toc}#{numbered}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          result << node.content
          result << "</section>"
        end
        result
      end

      def table node
=begin
[[id]]
.Title
|===
|col | col
|===
=end
        has_body = false
        result = []
        id = set_header_attribute "anchor", node.id
        result << %(<table#{id}>)
        result << %(<name>#{node.title}</name>) if node.title?
        # TODO iref belongs here
        [:head, :body, :foot].select {|tblsec| !node.rows[tblsec].empty? }.each do |tblsec|
          has_body = true if tblsec == :body
          # id = set_header_attribute "anchor", tblsec.id
          # not supported
          result << %(<t#{tblsec}>)
          node.rows[tblsec].each_with_index do |row, i|
            # id not supported on row
            result << "<tr>"
            rowlength = 0
            result1 = []
            row.each do |cell|
              id = set_header_attribute "anchor", cell.id
              colspan_attribute = set_header_attribute "colspan", cell.colspan
              rowspan_attribute = set_header_attribute "rowspan", cell.rowspan
              align = set_header_attribute("align", cell.attr("halign"))
              cell_tag_name = (tblsec == :head || cell.style == :header ? 'th' : 'td')
              entry_start = %(<#{cell_tag_name}#{colspan_attribute}#{rowspan_attribute}#{id}#{align}>)
              cell_content = cell.text
              rowlength += cell_content.size
              result1 << %(#{entry_start}#{cell_content}</#{cell_tag_name}>)
            end
            result << result1
            if rowlength > 72
              warn "asciidoctor: WARNING: row #{i} of table (count including header rows) is longer than 72 ascii characters:\n#{result1}"
            end
            result << "</tr>"
          end
          result << %(</t#{tblsec}>)
        end
        result << "</table>"

        warn "asciidoctor: WARNING: tables must have at least one body row" unless has_body
        result 
      end

      def listing node
        Asciidoctor::RFC::Common.listing(node, 3)
      end

      def ulist node
=begin
  [[id]]
  [empty=true,compact] (optional)
  * A
  * B
=end
        result = []
        if node.parent.context == :preamble and not $seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end
        id = set_header_attribute "anchor", node.id
        empty = get_header_attribute node, "empty"
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        result << "<ul#{id}#{empty}#{spacing}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>#{item.text}"
            result << item.content 
            result << "</li>"
          else
            result << "<li#{id}>#{item.text}</li>"
          end
        end
        result << "</ul>"
        result
      end

      (OLIST_TYPES = {
        arabic:     "1",
        # decimal:    "1", # not supported
        loweralpha: "a",
        # lowergreek: "lower-greek", # not supported
        lowerroman: "i",
        upperalpha: "A",
        upperroman: "I"
      }).default = "1"

      def olist node
=begin
  [[id]]
  [compact,start=n,group=n] (optional)
  . A
  . B
=end
        result = []
        if node.parent.context == :preamble and not $seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end
        id = set_header_attribute "anchor", node.id
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        start = get_header_attribute node, "start"
        group = get_header_attribute node, "group"
        type = set_header_attribute "type", OLIST_TYPES[node.style]
        result << "<ol#{id}#{spacing}#{start}#{group}#{type}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>#{item.text}"
            result << item.content
            result << "</li>"
          else
            result << "<li#{id}>#{item.text}</li>"
          end
        end
        result << "</ol>"
        result
      end

      def dlist node
=begin
  [[id]]
  [horizontal,compact] (optional)
  A:: B
  C:: D
=end
        result = []
        if node.parent.context == :preamble and not $seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end
        id = set_header_attribute "anchor", node.id
        hanging = set_header_attribute "hanging", "true" if node.option? "horizontal"
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        result << "<dl#{id}#{hanging}#{spacing}>"
        node.items.each do |terms, dd|
          [*terms].each do |dt|
            id = set_header_attribute "anchor", dt.id
            result << "<dt#{id}>#{dt.text}</dt>"
          end
          if dd.blocks?
            id = set_header_attribute "anchor", dd.id
            result << "<dd>#{dd.text}"
            result << dd.content
            result << "</dd>"
          else
            result << "<dd>#{dd.text}</dd>"
          end
        end
        result << "</dl>"
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
        $seen_abstract = false
        result << node.content
        if $seen_abstract
          result << "</abstract>"
        end
        result << "</front><middle>"
        result
      end
    end


    def sidebar node
=begin
[[id]]
****
Sidebar
****
=end
      result = []
      id = set_header_attribute "anchor", node.id
      result << "<aside#{id}>"
      result << cell.content
      result << "</aside>"
      result
    end


    def example node
=begin
.Title
====
Example
====
=end
      result = []
      id = set_header_attribute "anchor", node.id
      result << "<figure#{id}>"
      result << %(<name>#{node.title}</name>) if node.title?
      # TODO iref 
      result << node.content
      result << "</figure>"
      result.blocks.each do |b|
        unless b == :listing or b == :image or b == :literal
          warn "asciidoctor: WARNING: examples (figures) should only contain listings (sourcecode), images (artwork), or literal (artwork):\n#{b.text}"
        end
      end
      result
    end

    def inline_image node
      Asciidoctor::RFC::Common.inline_image(node, 3)
    end

    def image node
      Asciidoctor::RFC::Common.image(node, 3)
    end


    def verse 
      quote node
    end

  end
end