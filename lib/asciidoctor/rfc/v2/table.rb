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
        has_head = false
        style_value = case node.attr "grid"
                      when "all"
                        "all"
                      when "rows"
                        "headers"
                      when "cols"
                        "full"
                      when "none"
                        "none"
                      else
                        "full"
                      end

        warn "asciidoctor: WARNING (#{node.lineno}): grid=rows attribute is not supported on tables" if node.attr("grid") == "rows"
        texttable_attributes = {
          anchor: node.id,
          title: node.title,
          'suppress-title': node.attr("supress-title") ? true : false,
          align: node.attr("align"),
          style: style_value,
        }

        noko do |xml|
          xml.texttable **attr_code(texttable_attributes) do |xml_texttable|
            [:head, :body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
              has_body = true if tblsec == :body
              has_head = true if tblsec == :head
            end
            warn "asciidoctor: WARNING (#{node.lineno}): tables must have at least one body row" unless has_body
            warn "asciidoctor: WARNING (#{node.lineno}): tables must have at least one head row" unless has_head

            # preamble, postamble elements not supported
            table_head node, xml_texttable
            table_body_and_foot node, xml_texttable
          end
        end
      end

      private

      def table_head(node, xml)
        [:head].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
          warn "asciidoctor: WARNING (#{node.lineno}): RFC XML v2 tables only support a single header row" if node.rows[tblsec].size > 1
          widths = table_widths(node)
          node.rows[tblsec].each do |row|
            rowlength = 0
            row.each_with_index do |cell, i|
              warn "asciidoctor: WARNING (#{node.lineno}): RFC XML v2 tables do not support colspan attribute" unless cell.colspan.nil?
              warn "asciidoctor: WARNING (#{node.lineno}): RFC XML v2 tables do not support rowspan attribute" unless cell.rowspan.nil?
              width = if node.option?("autowidth") || i >= widths[:percentage].size || !widths[:named]
                        nil
                      else
                        "#{widths[:percentage][i]}%"
                      end
              ttcol_attributes = {
                # NOTE: anchor (ttcol.id) not supported
                align: cell.attr("halign"),
                width: width,
              }

              rowlength += cell.text.size
              xml.ttcol **attr_code(ttcol_attributes) do |ttcol|
                ttcol << cell.text
                # NOT cell.content: v2 does not permit blocks in cells
              end
            end
            warn "asciidoctor: WARNING (#{node.lineno}): header row of table is longer than 72 ascii characters" if rowlength > 72
          end
        end
      end

      def table_widths(node)
        percentage_widths = []
        named_widths = false
        node.columns.each do |col|
          percentage_widths << col.attr("colpcwidth")
          named_widths = true if col.attr("width") != 1
          # 1 is the default set value if no width has been given for the column
          # if a columns widths have been set as [1,1,1,1,...], they will be ignored
        end
        { percentage: percentage_widths, named: named_widths }
      end

      def table_body_and_foot(node, xml)
        [:body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
          # NOTE: anchor (tblsec.id) not supported
          node.rows[tblsec].each_with_index do |row, i|
            rowlength = 0
            row.each do |cell|
              rowlength += cell.text.size
              xml.c do |c|
                c << cell.text
                # NOT cell.content: v2 does not permit blocks in cells
              end
            end
            warn "asciidoctor: WARNING (#{node.lineno}): row #{i} of table is longer than 72 ascii characters" if rowlength > 72
          end
        end
      end
    end
  end
end
