require "../spec_helper"

def client
  Artifactory::Client.new
end

describe Artifactory::Client do
  context "configuration" do
    it "is a configurable object" do
      client.should be_a(Artifactory::Configurable)
    end

    it "users the default configuration" do
      Artifactory::Defaults.options.each do |key, value|
        client[key].should eq(value)
      end
    end

    it "uses the values in the initializer" do
      c = Artifactory::Client.new(username: "admin")
      c.username.should eq("admin")
    end

    it "can be modified after initialization" do
      c = client
      c.username.should eq(Artifactory::Defaults.username)
      c.username = "admin"
      c.username.should eq("admin")
    end
  end
end
