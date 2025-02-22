# frozen_string_literal: true

require_relative "lib/http_logger/version"

Gem::Specification.new do |spec|
  spec.name          = "http_logger"
  spec.version       = HttpLogger::VERSION
  spec.authors       = ["Bogdan Gusiev"]
  spec.email         = ["agresso@gmail.com"]

  spec.summary       = "Log your http api calls just like SQL queries"
  spec.description   = "This gem keeps an eye on every Net::HTTP library usage and dumps all request and response data to the log file."
  spec.homepage      = "https://github.com/railsware/http_logger"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files         = Dir.glob("{lib,spec}/**/*") + ["LICENSE.txt", "README.md"]
  spec.extra_rdoc_files = ["LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "webmock", ">= 3.0"
  spec.add_development_dependency "debug", ">= 1.0"
  spec.add_development_dependency "bump", ">= 0.10"
end

