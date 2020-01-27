$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'webmock/rspec'
require 'http_logger'
require "logger"
require "fileutils"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

LOGFILE = 'http.log'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  FileUtils.rm_f(LOGFILE)
  HttpLogger.logger = Logger.new(LOGFILE)
end
