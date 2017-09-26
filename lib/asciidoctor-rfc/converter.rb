require "Date"
require "pp"

module Asciidoctor
  module Rfc
    # A {Converter} implementation that generates RFC XML output, a format used to 
    # format RFC proposals (https://tools.ietf.org/html/rfc7991)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md

    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      register_for 'rfc'

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
:ipr
:obsoletes
:updates
:submissionType
:indexInclude
:iprExtract
:sortRefs
:symRefs
:tocInclude
=end
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        ipr = get_header_attribute node, "ipr"
        obsoletes = get_header_attribute node, "obsoletes"
        updates = get_header_attribute node, "updates"
        indexInclude = get_header_attribute node, "indexInclude"
        iprExtract = get_header_attribute node, "indexInclude"
        sortRefs = get_header_attribute node, "sortRefs"
        symRefs = get_header_attribute node, "symRefs"
        tocInclude = get_header_attribute node, "tocInclude"
        submissionType = get_header_attribute node, "submisionType", "IETF"
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
        result << "</middle>"
        result << (back node)
        result << "</rfc>"

        # <middle> needs to move after preamble
        if result.any? { |e| e == "</front><middle>" } and result.any? { |e| e == "</front><middle1>" }
          result = result.reject { |e| e == "</front><middle1>" }
        else
          result = result.map { |e| e == "</front><middle1>" ? "</front><middle>" : e }
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
        authorname = set_header_attribute "fullname", node.attr("author#{suffix}")
        surname = set_header_attribute "surname", node.attr("lastname#{suffix}")
        initials = set_header_attribute "initials", node.attr("firstname#{suffix}")[0]
        role = set_header_attribute "role", node.attr("role#{suffix}")
        organization = node.attr("organization#{suffix}")
        postalline = node.attr("postalline#{suffix}")
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
        result << "<organization>#{organization}</organization>" unless organization.nil?

        if not email.nil? or not facsimile.nil? or not uri.nil? or not phone.nil? or 
          not postalline.nil? or not street.nil?
          result << "<address>"
          if not postalline.nil? or not street.nil?
            result << "<postal>"
            if postalline.nil?
              result << "<street>#{street}</street>" unless street.nil?
              result << "<city>#{city}</city>" unless city.nil?
              result << "<region>#{region}</region>" unless region.nil?
              result << "<code>#{code}</code>" unless code.nil?
              result << "<country>#{country}</country>" unless country.nil?
            else
              postalline.split("\\ ").each { |p| result << "<postalLine>#{p}</postalLine>" }
            end
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

      def back node
        # TODO
      end

      def inline_anchor node
        case node.type
        when :xref
          # format attribute not supported
          unless (text = node.text) || (text = node.attributes['path'])
            refid = node.attributes['refid']
            text = %([#{refid}])
          end
          %(<xref target="#{node.target}">#{text}</a>)
        when :link
          %(<eref href="#{node.target}">#{node.text}</eref>)
        when :bibref
=begin
          # NOTE technically node.text should be node.reftext, but subs have already been applied to text
          %(<a id="#{node.id}"></a>#{node.text})
=end
        else
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
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
          node.text
        end
      end

      def paragraph node
=begin
   [[id]]
   [keepWithNext=true,keepWithPrevious=true] (optional)
   Text
=end
        result = []
        id = set_header_attribute "anchor", node.id
        if node.parent.context == :preamble
          result << "<abstract#{id}>"
          result << node.content
          result << "</abstract>"
        else
          id = set_header_attribute "anchor", node.id
          keepWithNext = get_header_attribute node, "keepWithNext"
          keepWithPrevious = get_header_attribute node, "keepWithPrevious"
          result << "<t#{id}#{keepWithNext}#{keepWithPrevious}>#{node.content}</t>"
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
   .Title
   ====
     Content
   ====

     [NOTE,removeInRFC=true]
   .Title
   ====
     Content
   ====
=end
        result = []
        if node.parent.context == :preamble
          removeInRFC = get_header_attribute node, "removeInRFC"
          result << "<note#{removeInRFC}>"
          result << "<name>#{node.title}</name>" unless node.title.nil?
          # TODO cref, eref, relref, tt, xref within name
          result << (paragraph1 node)
          # TODO dl ol ul
          result << "</note>"
        else
          # TODO
          result << "<note1>"
          result << node.content
          result << "</note1>"
        end
        result
      end

      def section node
=begin
   [[id]]
   [removeInRFC=true,toc=include|exclude|default] (optional)
   == title
   Content
=end
        result = []
        id = set_header_attribute "anchor", node.id
        removeInRFC = get_header_attribute node, "removeInRFC"
        toc = get_header_attribute node, "toc"
        numbered = set_header_attribute "numbered", node.attr?("sectnums")
        result << "<section#{id}#{removeInRFC}#{toc}#{numbered}>"
        result << "<name>#{node.title}</name>" unless node.title.nil?
        result << node.content
        result << "</section>"
        result
      end

      def ulist node
=begin
   [[id]]
   [empty=true,compact] (optional)
   * A
   * B
=end
        result = []
        id = set_header_attribute "anchor", node.id
        empty = get_header_attribute node, "empty"
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        result << "<ul#{id}#{empty}#{spacing}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>"
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
   [empty=true,compact,start=n,group=n] (optional)
   . A
   . B
=end
        result = []
        id = set_header_attribute "anchor", node.id
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        start = get_header_attribute node, "start"
        group = get_header_attribute node, "group"
        type = set_header_attribute node, "type", OLIST_TYPES[node.style]
        result << "<ol#{id}#{empty}#{spacing}#{start}#{group}#{type}>"
        node.items.each do |item|
          id = set_header_attribute "anchor", item.id
          if item.blocks?
            result << "<li#{id}>"
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
        id = set_header_attribute "anchor", node.id
        hanging = set_header_attribute "hanging", "true" if node.option? "horizontal"
        spacing = set_header_attribute "spacing", "compact" if node.option? "compact"
        result << "<dl#{id}#{hanging}#{spacing}>"
        node.items.each do |terms, dd|
          [*terms].each do |dt|
            id = set_header_attribute "anchor", dt.id
            result << "<dt#{id}>#{dt.text}</dt>"
          end
          if item.blocks?
            id = set_header_attribute "anchor", item.id
            result << "<dd#{id}>"
            result << dd.content
            result << "</dd>"
          else
            result << "<dd>#{item.text}</dd>"
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
        result << node.content
        result << "</front><middle>"
        result
      end
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
      #rules = (node.attr 'grid') ? 'all' : 'none'
      id = set_header_attribute "anchor", node.id
      result << %(<table#{id}">)
      result << %(<name>#{node.title}</name>) if node.title?
      # TODO iref belongs here
      [:head, :foot, :body].select {|tblsec| !node.rows[tblsec].empty? }.each do |tblsec|
        has_body = true if tblsec == :body
        # id = set_header_attribute "anchor", tblsec.id
        # not supported
        result << %(<t#{tblsec}>)
        node.rows[tblsec].each do |row|
          id = set_header_attribute "anchor", row.id
          result << "<tr#{id}>"
          row.each do |cell|
            id = set_header_attribute "anchor", row.id
            colspan_attribute = set_header_attribute "colspan", cell.colspan
            rowspan_attribute = set_header_attribute "rowspan", cell.rowspan
            align = set_header_attribute("align", cell.attr("halign"))
            cell_tag_name = (tblsec == :head || cell.style == :header ? 'th' : 'td')
            entry_start = %(<#{cell_tag_name}#{colspan_attribute}#{rowspan_attribute}#{id}#{align}>)
            cell_content = if cell.blocks?
                             cell.content
                           else
                             cell.text
                           end
            result << %(#{entry_start}#{cell_content}</#{cell_tag_name}>)
          end
          result << "</tr>"
        end
        result << %(</t#{tblsec}>)
      end
      result << "</table>"

      warn "asciidoctor: WARNING: tables must have at least one body row" unless has_body
      result 
    end




=begin
TODO
   2.3. <annotation> ..............................................12
   2.5. <artwork> .................................................13
   2.6. <aside> ...................................................17
   2.8. <back> ....................................................19
   2.9. <bcp14> ...................................................20
   2.10. <blockquote> .............................................20
   2.11. <boilerplate> ............................................22
   2.16. <cref> ...................................................23
   2.19. <displayreference> .......................................27
   2.25. <figure> .................................................32
   2.27. <iref> ...................................................35
   2.32. <name> ...................................................39
   2.39. <refcontent> .............................................44
   2.40. <reference> ..............................................45
   2.41. <referencegroup> .........................................46
   2.42. <references> .............................................46
   2.44. <relref> .................................................47
   2.48. <sourcecode> .............................................59
   2.53. <t> ......................................................64
=end

  end
end
