module Asciidoctor
  module RFC::V3
    module Base
      # Syntax:
      #   =Title
      #   Author
      #   :ipr
      #   :obsoletes
      #   :updates
      #   :submissionType
      #   :indexInclude
      #   :iprExtract
      #   :sortRefs
      #   :symRefs
      #   :tocInclude
      #   :tocDepth
      #
      #   ABSTRACT
      #
      #   NOTEs
      #
      #   ==first title
      #   CONTENT
      #
      #   [bibliography] # start of back matter
      #   == Bibliography
      #
      #   [appendix] # start of back matter if not already started
      #   == Appendix
      def document(node)
        $seen_back_matter = false
        $seen_abstract = false
        # If this is present, then BCP14 keywords in boldface are not assumed to be <bcp14> tags. By default they are.
        $bcp_bold = !(node.attr? "no-rfc-bold-bcp14")
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
        tocDepth = get_header_attribute node, "tocDepth"
        submissionType = get_header_attribute node, "submissionType", "IETF"
        t = Time.now.getutc
        preptime = set_header_attribute("preptime",
                                        sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",
                                                t.year, t.month, t.day, t.hour, t.min, t.sec))
        version = set_header_attribute "version", "3"
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}
        #{version}#{submissionType}#{indexInclude}#{iprExtract}#{sortRefs}#{symRefs}#{tocInclude}#{tocDepth}>)
        result << (link node)
        result << noko { |xml| front node, xml }

        result.last.last.gsub! /<\/front>$/, "" # FIXME: this is a hack!
        result << "</front><middle1>"
        result << node.content if node.blocks?
        result << ($seen_back_matter ? "</back>" : "</middle>")
        result << "</rfc>"

        # <middle> needs to move after preamble
        result = result.flatten
        result = if result.any? { |e| e =~ /<\/front><middle>/ } && result.any? { |e| e =~ /<\/front><middle1>/ }
                   result.reject { |e| e =~ /<\/front><middle1>/ }
                 else
                   result.map { |e| e =~ /<\/front><middle1>/ ? "</front><middle>" : e }
                 end

        result * "\n"
      end

      # Syntax:
      #   = Title
      #   Author
      #   :link href,href rel
      def link(node)
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

      def inline_break(node)
        %(#{node.text}<br/>)
      end

      def inline_quoted(node)
        case node.type
        when :emphasis
          "<em>#{node.text}</em>"
        when :strong
          if $bcp_bold &&
            node.text =~ /^(MUST|MUST NOT|REQUIRED|SHALL|SHALL NOT|SHOULD|SHOULD NOT|RECOMMENDED|MAY|OPTIONAL)$/
            "<bcp14>#{node.text}</bcp14>"
          else
            "<strong>#{node.text}</strong>"
          end
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
          # [bcp14]#MUST NOT#
          if node.role == "bcp14"
            "<bcp14>#{node.text.upcase}</bcp14>"
          else
            node.text
          end
        end
      end

      def inline_anchor(node)
        case node.type
        when :xref
          if text =~ /^\S+ (of|comma|parens|bare)\b/
            # <<crossreference#fragment,section (of|comma|parens|bare): text>> = relref
            relative = set_header_attribute "relative", node.attributes["fragment"]
            target = node.target.gsub(/\..*$/, "").gsub(/^#/, "")
            /(?<section>\S+)\s+(?<format>[a-z]+)(: )?(?<text1>.*)$/ =~ text
            section = set_header_attribute "section", section
            format = set_header_attribute "displayFormat", format
            target = set_header_attribute "target", target
            %(<relref#{relative}#{section}#{format}#{target}>#{text1}</relref>)
          else
            format = nil
            if text =~ /^format=(counter|title|none|default):/
              /^format=(?<format>\S+):\s*(?<text1>.*)$/ =~ text
              format = set_header_attribute "format", format
              text = text1
            end
            target = set_header_attribute "target", node.target.gsub(/^#/, "")
            %(<xref#{format}#{target}>#{text}</xref>)
          end
        when :link
          text = node.text
          text = nil if node.target == node.text
          %(<eref target="#{node.target}">#{text}</eref>)
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
          # If this is within referencegroup, output as bibanchor anyway
          if $processing_reflist
            %(<bibanchor="#{node.id}">) # will convert to anchor attribute upstream
          else
            warn %(asciidoctor: WARNING: anchor "#{node.id}" is not in a place where XML RFC will recognise it as an anchor attribute)
          end
        else
          warn %(asciidoctor: WARNING: unknown anchor type: #{node.type.inspect})
        end
      end

      # Syntax:
      #   [[id]]
      #   [keepWithNext=true,keepWithPrevious=true] (optional)
      #   Text
      def paragraph(node)
        result = []
        if node.parent.context == :preamble && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end
        id = set_header_attribute "anchor", node.id
        keepWithNext = get_header_attribute node, "keepWithNext"
        keepWithPrevious = get_header_attribute node, "keepWithPrevious"
        result << "<t#{id}#{keepWithNext}#{keepWithPrevious}>#{node.content}</t>"
        result
      end

      # Syntax:
      #   :sectnums: (toggle)
      #   :sectnums!: (toggle)
      #   [[id]]
      #   [removeInRFC=true,toc=include|exclude|default] (optional)
      #   == title
      #   Content
      #
      #   [[id]]
      #   [bibliography]
      #   == Normative|Informative References
      #   * [[[ref1]]] Ref [must provide references as list]
      #   * [[[ref2]]] Ref
      def section(node)
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
            result.unshift($xreftext.keys.map { |k| %(<displayreference target="#{k}" to="#{$xreftext[k]}"/>) })
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

      # Syntax:
      #   [[id]]
      #   .Name
      #   [link=xxx,align=left|center|right,alt=alt_text,type]
      #   image::filename[alt,width,height]
      # @note ignoring width, height attributes
      def image(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        link = (node.image_uri node.attr("target"))
        src = set_header_attribute "src", link
        type = set_header_attribute "type", link =~ /\.svg$/ ? "svg" : "binary-art"
        name = set_header_attribute "name", node.title
        width = get_header_attribute node, "width"
        height = get_header_attribute node, "height"
        result << "<artwork#{id}#{name}#{align}#{alt}#{type}#{src}#{width}#{height}/>"
        result << "</figure>" if node.parent.context != :example
        result
      end
    end
  end
end
