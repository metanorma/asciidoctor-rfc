module Asciidoctor
  module RFC::V3
    module Table
      # Syntax:
      #   [[id]]
      #   .Title
      #   |===
      #   |col | col
      #   |===
      def table(node)
        has_body = false
        result = []
        id = set_header_attribute "anchor", node.id
        result << %(<table#{id}>)
        result << %(<name>#{node.title}</name>) if node.title?
        # TODO iref belongs here
        [:head, :body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
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
              cell_tag_name = (tblsec == :head || cell.style == :header ? "th" : "td")
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
    end
  end
end
