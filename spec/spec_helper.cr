require "dotenv"
Dotenv.load if File.exists?(".env")

require "spec"
require "../src/artifactory"

TEST_REPO_NAME = "test-upload-repo"

def client
  Artifactory::Client.new
end

def cloud?
  ENV.fetch("ARTIFACTORY_CLOUD", "false") == "true"
end

def upload_repo
  Artifactory::Resource::Repository.new(key: TEST_REPO_NAME)
end

Spec.before_suite {
  # spoved_logger :trace, bind: true

  upload_repo.save
  Artifactory::Resource::Artifact.new(
    TEST_REPO_NAME, "test/test_upload.yml", "./shard.yml"
  ).upload(
    test: "true"
  )
}

Spec.after_suite {
  upload_repo.delete
}
