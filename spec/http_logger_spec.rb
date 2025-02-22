require 'spec_helper'
require "uri"
require "base64"

describe HttpLogger do

  before do
    # flush log
    f = File.open(LOGFILE, "w")
    f.close

    stub_request(:any, url).to_return(
      body: response_body,
      headers: {"X-Http-logger" => true, **response_headers},
    )
  end

  let(:response_body) { "Success" }
  let(:response_headers) { {} }
  let(:request_headers) { {} }

  let(:url) { "http://google.com/" }
  let(:uri) { URI.parse(url) }
  let(:request) do
    Net::HTTP.get_response(uri, **request_headers)
  end

  let(:long_body) do
    "12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n" * 50 +
      "12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n" * 50
  end

  subject do
    _context if defined?(_context)
    request
    File.read(LOGFILE)
  end

  it { should_not be_empty }

  context "when url has escaped chars" do

    let(:url) { "http://google.com?query=a%20b"}

    it { subject.should include("query=a b")}

  end

  context "when headers logging is on" do

    before(:each) do
      HttpLogger.configuration.log_headers = true
    end

    it { should include("HTTP response header") }
    it { should include("HTTP request header") }


    context "authorization header" do

      let(:request_headers) do
        {'Authorization' => "Basic #{Base64.encode64('hello:world')}".strip}
      end
      it { should include("Authorization: <filtered>") }
    end
  end

  describe "post request" do
    let(:body) {{:a => 'hello', :b => 1}}
    let(:request) do
      Net::HTTP.post_form(uri, body)
    end

    it {should include("Request body")}
    it {should include("a=hello&b=1")}
    context "with too long body" do
      let(:response_body) { long_body }
      let(:url) do
        "http://github.com/"
      end
      it { should include("12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n")}
      it { should include("<some data truncated>") }
      it { should include("12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n")}
    end

  end

  describe "put request" do
    let(:request) do
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri.path)
      request.set_form_data(:a => 'hello', :b => 1)
      http.request(request)
    end

    it {should include("Request body")}
    it {should include("a=hello&b=1")}
  end

  describe "generic request" do
    let(:request) do
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTPGenericRequest.new('PUT', true, true, uri.path)
      request.body = "a=hello&b=1"
      http.request(request)
    end

    it {should include("Request body")}
    it {should include("a=hello&b=1")}
  end

  context "when request body logging is off" do

    before(:each) do
      HttpLogger.configuration.log_request_body = false
    end

    let(:request) do
      Net::HTTP.post_form(uri, {})
    end

    it { should_not include("Request body") }

  end

  context "with long response body" do

    let(:response_body) { long_body }
    let(:url) do
      stub_request(:get, "http://github.com/").to_return(body: long_body)
      "http://github.com"
    end

    it { should include("12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n")}
    it { should include("<some data truncated>") }
    it { should include("12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n")}

  end

  context "when response body logging is off" do

    before(:each) do
      HttpLogger.configuration.log_response_body = false
    end

    let(:response_body) { long_body }
    let(:url) do
      "http://github.com"
    end

    it { should_not include("Response body") }
  end

  context "ignore option is set" do

    let(:url) do
      "http://rpm.newrelic.com/hello/world"
    end

    before(:each) do
      HttpLogger.configuration.ignore = [/rpm\.newrelic\.com/]
    end

    it { should be_empty}
  end

  context "when level is set" do

    let(:url) do
      stub_request(:get, "http://rpm.newrelic.com/hello/world").to_return(body: "")
      "http://rpm.newrelic.com/hello/world"
    end

    before(:each) do
      HttpLogger.configuration.level = :info
    end

    it { should_not be_empty }
  end

  after(:each) do
    HttpLogger.configuration.reset
  end
end
