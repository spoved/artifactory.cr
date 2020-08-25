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

    it "calculates checksum" do
      artifact = Artifactory::Resource::Artifact.new(
        TEST_REPO_NAME, "test/shards.yml", "./shard.yml"
      )
      artifact.sha1.should_not be_nil
    end

    it "can find by checksum" do
      results = Artifactory::Resource::Artifact.search(".*")
      arti = results.first
      arti.sha256.should_not be_nil

      res = Artifactory::Resource::Artifact.find_by_checksum("SHA256", arti.sha256.not_nil!)
      res.first.sha256.should eq arti.sha256
    end
  end
end
