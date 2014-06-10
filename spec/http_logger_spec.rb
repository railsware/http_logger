require 'spec_helper'
require "uri"

describe HttpLogger do

  before do
    # flush log
    f = File.open(LOGFILE, "w")
    f.close
  end

  let(:url) { "http://google.com/" }
  let(:uri) { URI.parse(url) }
  let(:request) do
    Net::HTTP.get_response(uri)
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
      HttpLogger.log_headers = true
    end

    it { should include("HTTP response header") }
    it { should include("HTTP request header") }

    after(:each) do
      HttpLogger.log_headers = false
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
      let(:url) do
        FakeWeb.register_uri(:post, "http://github.com", :body => long_body)
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
      HttpLogger.log_request_body = false
    end

    let(:request) do
      Net::HTTP.post_form(uri, {})
    end

    it { should_not include("Request body") }

    after(:each) do
      HttpLogger.log_request_body = true
    end
  end

  context "with long response body" do

    let(:url) do
      FakeWeb.register_uri(:get, "http://github.com", :body => long_body)
      "http://github.com"
    end

    it { should include("12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n")}
    it { should include("<some data truncated>") }
    it { should include("12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n")}

  end

  context "when response body logging is off" do

    before(:each) do
      HttpLogger.log_response_body = false
    end

    let(:url) do
      FakeWeb.register_uri(:get, "http://github.com", :body => long_body)
      "http://github.com"
    end

    it { should_not include("Response body") }

    after(:each) do
      HttpLogger.log_response_body = true
    end
  end

  context "ignore option is set" do

    let(:url) { "http://rpm.newrelic.com/hello/world"}

    before(:each) do
      HttpLogger.ignore = [/rpm\.newrelic\.com/]
    end

    it { should be_empty}
    
    after(:each) do
      HttpLogger.ignore = []
    end
  end

  context "when level is set" do

    let(:url) { "http://rpm.newrelic.com/hello/world"}

    before(:each) do
      HttpLogger.level = :info
    end

    it { should_not be_empty }
    
    after(:each) do
      HttpLogger.level = :debug
    end
  end
end
