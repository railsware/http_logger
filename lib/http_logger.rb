require 'net/http'
require "uri"

# Usage:
#
#    require 'http_logger'
#
# == Setup logger
#
#    HttpLogger.logger = Logger.new('/tmp/all.log')
#    HttpLogger.log_headers = true
#
# == Do request
#
#     res = Net::HTTP.start(url.host, url.port) { |http|
#       http.request(req)
#     }
#     ...
#
# == View the log
#
#     cat /tmp/all.log
class HttpLogger
  class << self
    attr_accessor :collapse_body_limit
    attr_accessor :log_headers
    attr_accessor :logger
    attr_accessor :colorize
  end

  self.log_headers = false
  self.colorize = true
  self.collapse_body_limit = 5000

  def self.perform(*args, &block)
    instance.perform(*args, &block)
  end

  def self.instance
    @instance ||= HttpLogger.new
  end

  def self.deprecate_config(option)
    warn "Net::HTTP.#{option} is deprecated. Use HttpLogger.#{option} instead."
  end

  def perform(http, request, request_body)
    start_time = Time.now
    response = yield
  ensure
    if require_logging?(http, request)
      log_request_url(http, request, start_time)
      log_post_put_params(request)
      log_request_headers(request)
      if defined?(response) && response
        log_response_code(response)
        log_response_headers(response)
        log_response_body(response.body)
      end
    end
  end

  protected

  def log_request_url(http, request, start_time)
    url = "http#{"s" if http.use_ssl?}://#{http.address}:#{http.port}#{request.path}"
    ofset = Time.now - start_time
    log("HTTP #{request.method} (%0.2fms)" % (ofset * 1000), URI.decode(url))
  end

  def log_request_headers(request)
    if self.class.log_headers
      request.each_capitalized { |k,v| log("HTTP request header", "#{k}: #{v}") }
    end
  end

  def log_post_put_params(request)
    body = request.body
    if body && !body.empty? && (request.is_a?(::Net::HTTP::Post) || request.is_a?(::Net::HTTP::Put))
      log("Request body", truncate_body(body))
    end
  end

  def log_response_code(response)
    log("Response status", "#{response.class} (#{response.code})")
  end

  def log_response_headers(response)
    if self.class.log_headers
      response.each_capitalized { |k,v| log("HTTP response header", "#{k}: #{v}") }
    end
  end

  def log_response_body(body)
    if body.is_a?(Net::ReadAdapter)
      log("Response body", "<impossible to log>")
    else
      if body && !body.empty?
        log("Response body", truncate_body(body))
      end
    end
  end

  def require_logging?(http, request)
    fakeweb = if defined?(::FakeWeb)
                uri = ::FakeWeb::Utility.request_uri_as_string(http, request)
                method = request.method.downcase.to_sym
                ::FakeWeb.registered_uri?(method, uri)
              else
                false
              end
    self.logger && (http.started? || fakeweb)
  end

  def truncate_body(body)
    if collapse_body_limit && collapse_body_limit > 0 && body.size >= collapse_body_limit
      body_piece_size = collapse_body_limit / 2
      body[0..body_piece_size] + 
        "\n\n<some data truncated>\n\n" + 
        body[(body.size - body_piece_size)..body.size]
    else
      body
    end
  end


  def log(message, dump)
    self.logger.debug(format_log_entry(message, dump))
  end

  def format_log_entry(message, dump = nil)
    if self.class.colorize
      message_color, dump_color = "4;32;1", "0;1"
      log_entry = "  \e[#{message_color}m#{message}\e[0m   "
      log_entry << "\e[#{dump_color}m%#{String === dump ? 's' : 'p'}\e[0m" % dump if dump
      log_entry
    else
      "%s  %s" % [message, dump]
    end
  end

  def logger
    self.class.logger
  end

  def collapse_body_limit
    self.class.collapse_body_limit
  end
end

class Net::HTTP

  def self.log_headers=(value)
    HttpLogger.deprecate_config("log_headers")
    HttpLogger.log_headers = value
  end

  def self.colorize=(value)
    HttpLogger.deprecate_config("colorize")
    HttpLogger.colorize = value
  end

  def self.logger=(value)
    HttpLogger.deprecate_config("logger")
    HttpLogger.logger = value
  end


  alias_method :request_without_logging,  :request

  def request(request, body = nil, &block)
    HttpLogger.perform(self, request, body) do
      request_without_logging(request, body, &block) 
    end
  end

end

if defined?(Rails)

  if !Rails.respond_to?(:application) || (Rails.application && Rails.application.config)
    # Rails2
    Rails.configuration.after_initialize do
      HttpLogger.logger = Rails.logger
    end
  elsif defined?(ActiveSupport) && ActiveSupport.respond_to?(:on_load)
    # Rails3
    ActiveSupport.on_load(:after_initialize) do
      HttpLogger.logger = Rails.logger
    end
  end
end


