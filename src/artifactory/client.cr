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
        ssl_private_key: ssl_pem_file,
        read_timeout: read_timeout,
      )

      headers = {
        "Content-Type" => "application/json",
        "Accept"       => "*/*",
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

    delegate get, get_raw,
      post, post_raw,
      put, put_raw, put_form, put_file,
      patch, patch_raw,
      delete, to: client
  end
end
