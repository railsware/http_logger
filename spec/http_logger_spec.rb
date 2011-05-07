require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HttpLogger" do

  subject do
    uri = URI.parse("http://google.com/")
    response = Net::HTTP.get_response(uri)
    File.read(LOGFILE)
  end

  it { should_not be_empty }

  context "with FakeWeb" do
    before(:all) do
      require 'fakeweb'
    end
    it {should_not be_empty}

    after(:all) do
      Object.send(:remove_const, "FakeWeb")
    end
    
  end
end
