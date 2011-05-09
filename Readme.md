# Net::HTTP logger

Simple gem that logs your HTTP api requests just like database queries


## Screenshot

* [Hoptoad](https://github.com/railsware/http_logger/raw/master/screenshots/hoptoad.png)
* [Simple get](https://github.com/railsware/http_logger/raw/master/screenshots/rails_console.png)
* [Solr](https://github.com/railsware/http_logger/raw/master/screenshots/solr.png)

## Installation

    gem install http_logger

## Usage

    require 'http_logger'

    Net::HTTP.logger = Logger.new(...) # defaults to Rails.logger if Rails is defined
    Net::HTTP.colorize = true # Default: true


## Alternative

Net::HTTP has a builtin logger that can be set via \#set\_debug\_output.
This method is only available at the instance level and it is not always accessible if used inside of a library. Also output of builtin debugger is not formed well for API debug purposes.

## Integration

If you are using Net::HTTP#request hackers like FakeWeb make sure you require http\_logger after all others because http\_logger always calls "super", rather than others.
