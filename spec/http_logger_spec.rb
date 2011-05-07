require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HttpLogger" do
  it "should log request" do
    uri = URI.parse("http://google.com/")

    response = Net::HTTP.get_response(uri)
    File.read(LOGFILE).should_not be_empty

  end
end
