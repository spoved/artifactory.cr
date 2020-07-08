require "./configurable"

module Artifactory
  # Client for the Artifactory API.
  #
  # @see http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
  class Client
    include Artifactory::Configurable
  end
end
