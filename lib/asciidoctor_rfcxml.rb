module AsciidoctorRfcXml
  class Parser
    def initialize(file_name)
      @file_name = file_name
      xml = File.open(@file_name) { |f| Nokogiri::XML(f) }
    end

    # format can be :html or :txt
    def convert(format)

    end


    def parse

    end
  end

  class Element
  end

  class Document
  end

  class Error
  end


  def main

  end

  if __FILE__== $0
    begin
      main
    rescue Interrupt => e
      nil
    end
  end
end
