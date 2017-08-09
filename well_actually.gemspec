# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'well_actually/version'

Gem::Specification.new do |spec|
  spec.name          = "well_actually"
  spec.version       = WellActually::VERSION
  spec.authors       = ["Andrew Rove"]
  spec.email         = ["andrew@realsavvy.com"]

  spec.summary       = %q{Easy safe overwrites.}
  spec.description   = %q{Allows you to overwrite using an overwrite hash.}
  spec.homepage      = "https://www.realsavvy.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|gemfiles)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "appraisal", "~> 2.2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
