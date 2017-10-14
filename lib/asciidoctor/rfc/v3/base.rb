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
        xmllang = set_header_attribute "xml:lang", node.attr("xml-lang")
        t = Time.now.getutc
        preptime = set_header_attribute("preptime",
                                        sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",
                                                t.year, t.month, t.day, t.hour, t.min, t.sec))
        version = set_header_attribute "version", "3"
        result << %(<rfc#{document_ns_attributes node}#{ipr}#{obsoletes}#{updates}#{preptime}#{xmllang}
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
        result << noko do |xml|
          links = (node.attr("link") || "").split(/,/)
          links.each do |link|
            matched = /^(?<href>\S+)\s+(?<rel>\S+)$/.match link
            link_attributes = {
              href: matched.nil? ? link : matched[:href],
              rel: matched.nil? ? nil : matched[:rel],
            }.reject { |_, value| value.nil? }
            xml.link **link_attributes
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
          text = node.text
          if text =~ /^\S+ (of|comma|parens|bare)\b/
            # <<crossreference#fragment,section (of|comma|parens|bare): text>> = relref
            matched = /(?<section>\S+)\s+(?<format>[a-z]+)(: )?(?<text>.*)$/.match node.text

            relref_contents = matched[:text]

            relref_attributes = {
              relative: node.attributes["fragment"],
              section: matched[:section],
              displayFormat: matched[:format],
              target: node.target.gsub(/\..*$/, "").gsub(/^#/, ""),
            }.reject { |_, value| value.nil? }

            noko do |xml|
              xml.relref relref_contents, **relref_attributes
            end.join
          else
            matched = /^format=(?<format>counter|title|none|default):\s*(?<text>.*)$/.match node.text
            matched ||= {}
            xref_contents = matched[:text] || node.text

            xref_attributes = {
              format: matched[:format],
              target: node.target.gsub(/^#/, ""),
            }.reject { |_, value| value.nil? }

            noko do |xml|
              xml.xref xref_contents, **xref_attributes
            end.join
          end
        when :link
          eref_contents = node.target == node.text ? nil : node.text

          eref_attributes = {
            target: node.target,
          }.reject { |_, value| value.nil? }

          noko do |xml|
            xml.eref eref_contents, **eref_attributes
          end.join
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

        if (node.parent.context == :preamble) && !$seen_abstract
          $seen_abstract = true
          result << "<abstract>"
        end

        t_attributes = {
          anchor: node.id,
          keepWithNext: node.attr("keep-with-next"),
          keepWithPrevious: node.attr("keep-with-previous"),
        }.reject { |_, value| value.nil? }

        result << noko do |xml|
          xml.t **t_attributes do |xml_t|
            xml_t << node.content
          end
        end

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
        uri = node.image_uri node.attr("target")
        artwork_attributes = {
          align: node.attr("align"),
          alt: node.alt,
          anchor: node.id,
          height: node.attr("height"),
          name: node.title,
          src: uri,
          type: (uri =~ /\.svg$/ ? "svg" : "binary-art"),
          width: node.attr("width"),
        }.reject { |_, value| value.nil? }

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.artwork **artwork_attributes
            end
          else
            xml.artwork **artwork_attributes
          end
        end
      end
    end
  end
end
