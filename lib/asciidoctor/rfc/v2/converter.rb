require "asciidoctor"

require "asciidoctor/rfc/version"
require "asciidoctor/rfc/common/base"
require "asciidoctor/rfc/common/front"
require "asciidoctor/rfc/v2/base"
require "asciidoctor/rfc/v2/blocks"
require "asciidoctor/rfc/v2/front"
require "asciidoctor/rfc/v2/inline_anchor"
require "asciidoctor/rfc/v2/lists"
require "asciidoctor/rfc/v2/table"
require "asciidoctor/rfc/v2/validate"

module Asciidoctor
  module RFC::V2
    # A {Converter} implementation that generates RFC XML 2 output, a format used to
    # format RFC proposals (https://tools.ietf.org/html/rfc7749)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md
    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      include ::Asciidoctor::RFC::Common::Base
      include ::Asciidoctor::RFC::Common::Front
      include ::Asciidoctor::RFC::V2::Base
      include ::Asciidoctor::RFC::V2::Blocks
      include ::Asciidoctor::RFC::V2::Front
      include ::Asciidoctor::RFC::V2::InlineAnchor
      include ::Asciidoctor::RFC::V2::Lists
      include ::Asciidoctor::RFC::V2::Table
      include ::Asciidoctor::RFC::V2::Validate

      register_for "rfc2"

      $seen_back_matter = false
      $seen_abstract = false
      $xreftext = {}

      def initialize(backend, opts)
        super
        basebackend "html"
        outfilesuffix ".xml"
      end

      # alias_method :pass, :content
      alias_method :embedded, :content
      alias_method :sidebar, :content
      alias_method :audio, :skip
      alias_method :colist, :skip
      alias_method :page_break, :skip
      alias_method :thematic_break, :skip
      alias_method :video, :skip
      alias_method :inline_button, :skip
      alias_method :inline_kbd, :skip
      alias_method :inline_menu, :skip
      alias_method :inline_image, :skip

      alias_method :stem, :literal
      alias_method :quote, :paragraph
    end
  end
end
