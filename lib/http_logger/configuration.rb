class HttpLogger
  class Configuration
    attr_accessor :collapse_body_limit
    attr_accessor :log_headers
    attr_accessor :log_request_body
    attr_accessor :log_response_body
    attr_accessor :logger
    attr_accessor :colorize
    attr_accessor :ignore
    attr_accessor :level

    def initialize
      reset
    end

    def reset
      self.log_headers = false
      self.log_request_body = true
      self.log_response_body = true
      self.colorize = true
      self.collapse_body_limit = 5000
      self.ignore = []
      self.level = :debug
    end
  end
end
