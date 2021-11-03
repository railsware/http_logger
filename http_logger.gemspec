# frozen_string_literal: true
# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "http_logger/version"

Gem::Specification.new do |s|
  s.name = "http_logger".freeze
  s.version = HttpLogger::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bogdan Gusiev".freeze]
  s.date = "2020-01-27"
  s.description = "This gem keep an eye on every Net::HTTP library usage and dump all request and response data to the log file".freeze
  s.email = "agresso@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "Rakefile",
    "Readme.md",
    "VERSION",
    "http_logger.gemspec",
    "lib/http_logger.rb",
    "screenshots/hoptoad.png",
    "screenshots/rails_console.png",
    "screenshots/solr.png",
    "spec/http_logger_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/railsware/http_logger".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.8".freeze
  s.summary = "Log your http api calls just like SQL queries".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 0"])
  end
end

