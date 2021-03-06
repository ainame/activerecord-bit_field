# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/bit_field/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-bit_field"
  spec.version       = ActiveRecord::BitField::VERSION
  spec.authors       = ["ainame"]
  spec.email         = ["s.namai.09@gmail.com"]
  spec.summary       = %q{provide a feature of mapping bit fileds to RDB table in ActiveRecord.}
  spec.description   = %q{Activerecord::BitField provide a feature of mapping bit fileds to RDB table in ActiveRecord.}
  spec.homepage      = "https://github.com/ainame/activerecord-bit_field"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", '>= 3.0.0'
  spec.add_runtime_dependency "activerecord", '>= 3.0.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
end
