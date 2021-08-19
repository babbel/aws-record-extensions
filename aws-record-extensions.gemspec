lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aws-record-extensions/version"

Gem::Specification.new do |spec|
  spec.name          = "aws-record-extensions"
  spec.version       = AwsRecordExtensions::VERSION
  spec.authors       = ["Aliaksei Kliuchnikau"]
  spec.email         = ["akliuchnikau@babbel.com"]

  spec.summary       = "Various extensions for aws-record gem."
  spec.description   = "Various extensions for aws-record gem."
  spec.homepage      = "https://github.com/babbel/aws-record-extensions"
  spec.license       = "Apache-2.0"

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-record"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "money"

  spec.add_development_dependency "activemodel"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec", "~> 3.0"
end
