module Asciidoctor
  module RFC::V2
    module Table
      # Syntax:
      #   [[id]]
      #   .Title
      #   [suppress-title,align,style]
      #   |===
      #   |col | col
      #   |===
      def table(node)
        has_body = false
        result = []
        id = set_header_attribute "anchor", node.id
        title = set_header_attribute "title", node.title
        suppresstitle = get_header_attribute node, "suppress-title"
        align = get_header_attribute node, "align"
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
          if node.rows[tblsec].size > 1
            warn "asciidoctor: WARNING: RFC XML v2 tables only support a single header row"
          end
          widths = []
          node.columns.each { |col| widths << col.attr("colpcwidth") }
          node.rows[tblsec].each do |row|
            rowlength = 0
            result1 = []
            row.each_with_index do |cell, i|
              id = set_header_attribute "anchor", cell.id
              align = set_header_attribute("align", cell.attr("halign"))
              width = if !node.option?("autowidth") && (i < widths.size)
                        set_header_attribute("width", "#{widths[i]}%")
                      end
              warn "asciidoctor: WARNING: RFC XML v2 tables do not support colspan attribute" unless cell.colspan.nil?
              warn "asciidoctor: WARNING: RFC XML v2 tables do not support rowspan attribute" unless cell.rowspan.nil?
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
    end
  end
end
