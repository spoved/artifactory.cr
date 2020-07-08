require "./configurable"

module Artifactory
  # Client for the Artifactory API.
  #
  # @see http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
  class Client
    include Artifactory::Configurable

    # Determine if the given options are the same as ours.
    def same_options?(opts) : Bool
      opts == options
    end
  end
end
