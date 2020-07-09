require "./version"

module Artifactory
  module Defaults
    # Default API endpoint
    ENDPOINT = "http://localhost:8080"

    # Default User Agent header string
    USER_AGENT = "Artifactory Crystal Shard #{Artifactory::VERSION}"

    module ClassMethods
      # The list of calculated default options for the configuration.
      def options
        {% begin %}
        {
          {% for key in Configurable::KEYS %}
          {{key}} => {{key.id}},
          {% end %}
        }
        {% end %}
      end

      # The endpoint where artifactory lives
      def endpoint : String
        ENV.fetch("ARTIFACTORY_ENDPOINT", ENDPOINT)
      end

      # The User Agent header to send along
      def user_agent : String
        ENV.fetch("ARTIFACTORY_USER_AGENT", USER_AGENT)
      end

      # The HTTP Basic Authentication username
      def username : String?
        ENV["ARTIFACTORY_USERNAME"]?
      end

      # The HTTP Basic Authentication password
      def password : String?
        ENV["ARTIFACTORY_PASSWORD"]?
      end

      # The API Access Token for authentication
      def access_token : String?
        ENV["ARTIFACTORY_ACCESS_TOKEN"]?
      end

      # The API Key for authentication
      def api_key : String?
        ENV["ARTIFACTORY_API_KEY"]?
      end

      # The HTTP Proxy server address as a string
      def proxy_address : String?
        ENV["ARTIFACTORY_PROXY_ADDRESS"]?
      end

      # The HTTP Proxy user password as a string
      def proxy_password : String?
        ENV["ARTIFACTORY_PROXY_PASSWORD"]?
      end

      # The HTTP Proxy server port as a int
      def proxy_port : Int32?
        ENV["ARTIFACTORY_PROXY_PORT"]? ? ENV["ARTIFACTORY_READ_TIMEOUT"].to_i : nil
      end

      # The HTTP Proxy server username as a string
      def proxy_username : String?
        ENV["ARTIFACTORY_PROXY_USERNAME"]?
      end

      # The path to a pem file on disk for use with a custom SSL verification
      def ssl_pem_file : String?
        ENV["ARTIFACTORY_SSL_PEM_FILE"]?
      end

      # Verify SSL requests (default: true)
      def ssl_verify : Bool
        if ENV["ARTIFACTORY_SSL_VERIFY"]?.nil?
          true
        else
          %w{t y}.includes?(ENV["ARTIFACTORY_SSL_VERIFY"].downcase[0])
        end
      end

      # Number of seconds to wait for a response from Artifactory
      def read_timeout : Int32
        if ENV["ARTIFACTORY_READ_TIMEOUT"]?
          ENV["ARTIFACTORY_READ_TIMEOUT"].to_i
        else
          120
        end
      end
    end

    extend ClassMethods
  end
end
