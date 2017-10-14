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
        noko do |xml|
          has_body = false
          # TODO iref belongs here

          table_attributes = {
            anchor: node.id
          }.reject { |_, value| value.nil? }

          xml.table **table_attributes do |xml_table|
            xml_table.name node.title if node.title?

            [:head, :body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
              tblsec_tag = "t#{tblsec}"

              has_body = true if tblsec == :body
              # "anchor" attribute from tblsec.id not supported
              xml_table.send tblsec_tag do |xml_tblsec|
                node.rows[tblsec].each_with_index do |row, i|
                  # id not supported on row
                  xml_tblsec.tr do |xml_tr|
                    rowlength = 0
                    row.each do |cell|
                      cell_attributes = {
                        anchor: cell.id,
                        colspan: cell.colspan,
                        rowspan: cell.rowspan,
                        align: cell.attr("halign"),
                      }.reject { |_, value| value.nil? }

                      cell_tag = (tblsec == :head || cell.style == :header ? "th" : "td")

                      rowlength += cell.text.size
                      xml_tr.send cell_tag, cell.text, **cell_attributes
                    end
                    warn "asciidoctor: WARNING: row #{i} of table (count including header rows) is longer than 72 ascii characters" if rowlength > 72
                  end
                end
              end
            end
          end
          warn "asciidoctor: WARNING: tables must have at least one body row" unless has_body
        end
      end
    end
  end
end
