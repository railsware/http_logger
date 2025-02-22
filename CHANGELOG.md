# Changelog

## [1.0.1]

* Modernize gemspec

## [1.0.0]

### Added
- Introduced a new `Configuration` class for `HttpLogger` to manage settings.
- Added support for binary response detection and logging.
- Added a new spec for binary response handling.

### Changed
- Updated `Gemfile` to use `gemspec` instead of listing development dependencies directly.
- Refactored `HttpLogger` to use a configuration object for managing settings.
- Updated `Readme.md` with new configuration example using `HttpLogger.configure`.

### Removed
- Removed `Gemfile.lock` from version control.

## Configuration Example

```ruby
HttpLogger.configure do |c|
  c.logger = Logger.new('/path/to/logfile.log')
  c.colorize = true
  c.ignore = [/example\.com/]
  c.log_headers = true
  c.log_request_body = true
  c.log_response_body = true
  c.level = :info
  c.collapse_body_limit = 5000
end
```

## Output Example for Binary Body

When a binary response is detected, the log will include a message indicating the binary content and its size:

```
Response body: <binary 41887 bytes>
```

