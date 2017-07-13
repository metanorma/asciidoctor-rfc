# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ascii_doctor_rfc/version"

Gem::Specification.new do |spec|
  spec.name          = "ascii_doctor_rfc"
  spec.version       = AsciiDoctorRFC::VERSION
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

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
end
