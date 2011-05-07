# Net::HTTP logger

Simple gem that logs your HTTP api requests just like database queries


## Screenshot

* [Hoptoad]()
* [Google]()

## Installation

    gem install http_logger

## Usage

    require 'http_logger'

    Net::HTTP.logger = Logger.new(...) # defaults to Rails.logger if Rails is defined
    Net::HTTP.colorize = true # Default: true


## Alternative

Net::HTTP has a builtin logger that can be set via \#set\_debug\_output.
This is only available at the instance control level which is not always accessible because it's wrapped by another class. Also it is not formed well for API debug purposes.
