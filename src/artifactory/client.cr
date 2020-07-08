require "./configurable"
require "spoved/api/client"

module Artifactory
  # Client for the Artifactory API.
  #
  # @see http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
  class Client
    include Artifactory::Configurable

    private property _client : Spoved::Api::Client? = nil

    private def build_api_client : Spoved::Api::Client
      uri = URI.parse(endpoint)

      c = Spoved::Api::Client.new(
        host: uri.host.as(String),
        port: uri.port,
        scheme: uri.scheme.as(String),
        api_path: uri.path.lchop("/"),
        user: username,
        pass: password,
        tls_verify_mode: ssl_verify ? OpenSSL::SSL::VerifyMode::PEER : OpenSSL::SSL::VerifyMode::NONE,
      )

      headers = {
        "Content-Type" => "application/json",
        "Accept"       => "application/json",
        "Connection"   => "keep-alive",
        "Keep-Alive"   => "30",
      }
      headers["X-JFrog-Art-Api"] = api_key.not_nil! unless api_key.nil?
      headers["Authorization"] = "Bearer #{access_token}" unless access_token.nil?

      c.default_headers.merge! headers
      c
    end

    private def client : Spoved::Api::Client
      @_client ||= build_api_client
    end

    def ping?
      client.get_raw("router/api/v1/system/ping").success?
    end

    # Determine if the given options are the same as ours.
    def same_options?(opts) : Bool
      opts == options
    end

    # Construct a URL from the given verb and path. If the request is a GET or
    # DELETE request, the params are assumed to be query params are are
    # converted as such using {Client#to_query_string}.
    #
    # If the path is relative, it is merged with the {Defaults.endpoint}
    # attribute. If the path is absolute, it is converted to a URI object and
    # returned.
    #
    # @param [Symbol] verb
    #   the lowercase HTTP verb (e.g. :+get+)
    # @param [String] path
    #   the absolute or relative HTTP path (url) to get
    # @param [Hash] params
    #   the list of params to build the URI with (for GET and DELETE requests)
    #
    # @return [URI]
    #
    def build_uri(verb, path, params)
      # Add any query string parameters
      if %i{delete get}.include?(verb)
        path = [path, to_query_string(params)].compact.join("?")
      end

      # Parse the URI
      uri = URI.parse(path)

      # Don't merge absolute URLs
      uri = URI.parse(File.join(endpoint, path)) unless uri.absolute?

      # Return the URI object
      uri
    end
  end
end
