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

  context "with long response body" do

    let(:body) do
      "12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n" * 50 +
        "12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n" * 50
    end

    let(:url) do
      FakeWeb.register_uri(:get, "http://github.com", :body => body)
      "http://github.com"
    end

    it { should include("12,Dodo case,dodo@case.com,tech@dodcase.com,single elimination\n")}
    it { should include("<some data truncated>") }
    it { should include("12,Bonobos,bono@bos.com,tech@bonobos.com,double elimination\n")}

  end
end
