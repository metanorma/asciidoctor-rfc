module Asciidoctor
  module RFC::V2
    module Base
      # Syntax:
      #   =Title
      #   Author
      #   :category
      #   :consensus
      #   :name
      #   :number
      #
      #   :ipr
      #   :obsoletes
      #   :updates
      #   :submissionType
      #   :indexInclude
      #   :ipr-extract
      #   :sort-refs
      #   :sym-refs
      #   :toc-include
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
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        doctype = node.attr "doctype"
        is_rfc = (doctype == "rfc")
        category = get_header_attribute node, "category"
        consensus = get_header_attribute node, "consensus"
        if is_rfc
          number = set_header_attribute "number", node.attr("name")
        else
          docName = set_header_attribute "docName", node.attr("name")
        end
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
          # [bcp14]#MUST NOT#
          if node.role == "bcp14"
            %(<spanx style="strong">#{node.text.upcase}</spanx>)
          else
            node.text
          end
        end
      end

      def inline_anchor(node)
        case node.type
        when :xref
          # format attribute not supported
          unless (text = node.text) || (text = node.attributes["path"])
            refid = node.attributes["refid"]
            #text = %([#{refid}])
          end
          format = nil
          if text =~ /^format=(counter|title|none|default):/
            /^format=(?<format>\S+):\s*(?<text1>.*)$/ =~ text
            format = set_header_attribute "format", format
            text = text1
          end
          target = set_header_attribute "target", node.target.gsub(/^#/, "")
          %(<xref#{format}#{target}>#{text}</xref>)
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
      #   Text
      def paragraph(node)
        result = []
        if (node.parent.context == :preamble) && (not $seen_abstract)
          result << "<abstract>"
          $seen_abstract = true
        end
        id = set_header_attribute "anchor", node.id
        result << "<t#{id}>#{node.content}</t>"
        result
      end

      def verse(node)
        result = []
        if (node.parent.context == :preamble) && (not $seen_abstract)
          result << "<abstract>"
          $seen_abstract = true
        end
        id = set_header_attribute "anchor", node.id
        result << "<t#{id}>#{node.content.gsub("\n", "<br/>\n")}</t>"
        result
      end


      # Syntax:
      #   [[id]]
      #   == title
      #   Content
      #
      #   [bibliography]
      #   == Normative|Informative References
      #   * [[[ref1]]] Ref [must provide references as list]
      #   * [[[ref2]]] Ref
      def section(node)
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

      # Syntax:
      #   [[id]]
      #   .Name
      #   [link=xxx,align=left|center|right,alt=alt_text,type]
      #   image::filename[alt_text,width,height]
      # @note ignoring width, height attributes
      def image(node)
        result = []
        result << "<figure>" if node.parent.context != :example
        id = set_header_attribute "anchor", node.id
        align = get_header_attribute node, "align"
        alt = set_header_attribute "alt", node.alt
        link = (node.image_uri node.attr("target"))
        src = set_header_attribute "src", link
        type = get_header_attribute node, "type"
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
