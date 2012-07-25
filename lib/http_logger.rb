require 'net/http'
require "uri"

# Usage:
#
#    require 'http_logger'
#
# == Setup logger
#
#    Net::HTTP.logger = Logger.new('/tmp/all.log')
#    Net::HTTP.log_headers = true
#
# == Do request
#
#     res = Net::HTTP.start(url.host, url.port) { |http|
#       http.request(req)
#     }
#     ...

class Net::HTTP

  class << self
    attr_accessor :log_headers
    attr_accessor :logger
    attr_accessor :colorize
  end

  self.log_headers = false
  self.colorize = true


  alias_method :request_without_logging,  :request

  def request(request, body = nil, &block)
    time = Time.now
    response = request_without_logging(request, body, &block)
    response
  ensure
    if self.require_logging?(request)
      url = "http#{"s" if self.use_ssl?}://#{self.address}:#{self.port}#{request.path}"
      ofset = Time.now - time
      log("HTTP #{request.method} (%0.2fms)" % (ofset * 1000), URI.decode(url))
      request.each_capitalized { |k,v| log("HTTP request header", "#{k}: #{v}") } if self.class.log_headers
      if request.is_a?(::Net::HTTP::Post) || request.is_a?(::Net::HTTP::Put)
        log("#{request.class.to_s.upcase} params", request.body)
      end
      if defined?(response) && response
        log("Response status", "#{response.class} (#{response.code})") 
        response.each_capitalized { |k,v| log("HTTP response header", "#{k}: #{v}") } if self.class.log_headers
        body = response.body
        log("Response body", body) unless body.is_a?(Net::ReadAdapter)
      end
    end
  end

  def require_logging?(request)
    fakeweb = if defined?(::FakeWeb)
                uri = ::FakeWeb::Utility.request_uri_as_string(self, request)
                method = request.method.downcase.to_sym
                ::FakeWeb.registered_uri?(method, uri)
              else
                false
              end
    self.logger && (self.started? || fakeweb)
  end


  protected
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

end


if defined?(Rails)
  Net::HTTP.logger = Rails.logger
end


