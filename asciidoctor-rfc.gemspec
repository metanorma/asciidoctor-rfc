# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciidoctor-rfc3/version"
require "asciidoctor-rfc2/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-rfc"
  spec.version       = Asciidoctor::Rfc3::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]
  spec.summary       = %q{todo: AsciiDoctorRFC description.}
  spec.homepage      = "https://github.com/riboseinc/asciidoctor-rfc"
  spec.license       = "MIT"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.1.9")

  spec.add_dependency "asciidoctor"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "timecop", "~> 0.9"

end
