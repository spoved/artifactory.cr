require "../../spec_helper"
require "uuid"

describe Artifactory::Resource::Artifact do
  describe "#search" do
    it "can locate artifact" do
      results = Artifactory::Resource::Artifact.search(".*")
      results.should be_a(Array(Artifactory::Resource::Artifact))
      results.should_not be_empty
    end

    it "can upload file" do
      Artifactory::Resource::Artifact.search("test/shards.yml", TEST_REPO_NAME).should be_empty
      uuid = UUID.random

      resp = Artifactory::Resource::Artifact.new(
        TEST_REPO_NAME, "test/shards.yml", "./shard.yml"
      ).upload(version: "1.0", uuid: uuid)

      resp.should be_a Artifactory::Resource::Artifact
    end
  end
end
