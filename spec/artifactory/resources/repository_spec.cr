require "../../spec_helper"

describe Artifactory::Resource::Repository do
  describe ".all" do
    it "returns an array of repository objects" do
      results = Artifactory::Resource::Repository.all
      results.should be_a(Array(Artifactory::Resource::Repository))
      results.should_not be_empty
    end
  end

  describe ".save" do
    it "Create and delete new repository" do
      repo = Artifactory::Resource::Repository.new(key: "test-repo")
      repo.save.should be_true
      repo.delete.should be_true
    end
  end
end
