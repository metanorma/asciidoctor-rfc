# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciidoctor/rfc/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-rfc"
  spec.version       = Asciidoctor::RFC::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = 'asciidoctor-rfc lets you write Internet-Drafts and RFCs in AsciiDoc.'
  spec.description   = <<~DESCRIPTION
asciidoctor-rfc lets you write Internet-Drafts and RFCs in a native
"asciidoctor" syntax.

RFC XML ("xml2rfc" Vocabulary XML, RFC7322) is the XML-based language used for
writing Internet-Drafts and RFCs, but not everyone likes hand-crafting XML,
especially when the focus should be on the content.

Specifically, the gem provides two things. First, an "asciidoctor" like syntax
that lets you utilize close to all features of native RFC XML, and maps most
asciidoctor textual syntax (like tables) into RFC XML features. Then, RFC XML
v3 (RFC 7991) and v2 (RFC 7749) backends that lets you render your AsciiDoc
into, you guessed it, RFC XML v3 and v2.

This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/riboseinc/asciidoctor-rfc"
  spec.license       = "MIT"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "asciidoctor", "~> 1.5.6"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "nokogiri", "~> 1.8.1"
  spec.add_dependency "thread_safe"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "rubocop", "~> 0.50"
end
