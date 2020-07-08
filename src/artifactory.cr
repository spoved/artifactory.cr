require "./artifactory/*"

module Artifactory
  @@client : Client? = nil

  def self.client(options : Artifactory::Configurable::Options? = nil)
    if !@@client.nil?
      @@client = Client.new(options)
    elsif !@@client.same_options?(options)
      @@client = Client.new(options)
    end
    @@client.not_nil!
  end

  def self.setup
    @@client = Client.new
  end
end

# Load the initial default values
Artifactory.setup
