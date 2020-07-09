require "dotenv"
Dotenv.load if File.exists?(".env")

require "spec"
require "../src/artifactory"

def client
  Artifactory::Client.new
end

def cloud?
  ENV.fetch("ARTIFACTORY_CLOUD", "false") == "true"
end

def upload_repo
  Artifactory::Resource::Repository.new(key: "test-upload-repo")
end

Spec.before_suite {
  # spoved_logger :trace, bind: true

  upload_repo.save
}

Spec.after_suite {
  upload_repo.delete
}
