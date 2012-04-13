require 'spec_helper'
require 'fakeweb'
require "uri"

describe "HttpLogger" do

  before do
    # flush log
    f = File.open(LOGFILE, "w")
    f.close
  end

  let(:url) { "http://google.com/" }
  let(:uri) { URI.parse("http://google.com/") }
  let(:request) do
    Net::HTTP.get_response(uri)
  end

  subject do
    request
    File.read(LOGFILE)
  end

  it { should_not be_empty }

  context "when headers logging is on" do

    before(:each) do
      Net::HTTP.log_headers = true
    end

    it { should include("HTTP response header") }
    it { should include("HTTP request header") }

    after(:each) do
      Net::HTTP.log_headers = false
    end
    
  end

  describe "post request" do
    let(:request) do
      Net::HTTP.post_form(uri, {:a => 'hello', :b => 1})
    end

    it {should include("POST params")}
    it {should include("a=hello&b=1")}
  end
  describe "put request" do
    let(:request) do
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri.path)
      request.set_form_data(:a => 'hello', :b => 1)
      http.request(request)
    end

    it {should include("a=hello&b=1")}
    it {should include("PUT params")}
  end
end
