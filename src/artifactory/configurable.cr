module Artifactory
  module Configurable
    KEYS = {
      :endpoint       => String,
      :username       => String,
      :password       => String,
      :api_key        => String,
      :proxy_address  => String,
      :proxy_password => String,
      :proxy_port     => Int32,
      :proxy_username => String,
      :ssl_pem_file   => String,
      :ssl_verify     => Bool,
      :user_agent     => String,
      :read_timeout   => Int32,
    }

    {% begin %}
      {% for key, ktype in Artifactory::Configurable::KEYS %}
        property {{key.id}} : {{ktype}}? = nil
      {% end %}
    {% end %}

    macro included
      def initialize(
        {% for key, ktype in Artifactory::Configurable::KEYS %}
          @{{key.id}} : {{ktype}}? = nil,
        {% end %}
      )
        {% for key, ktype in Artifactory::Configurable::KEYS %}
        self.{{key.id}} = Artifactory::Defaults.{{key.id}} if {{key.id}}.nil?
        {% end %}
      end
    end

    def reset!
      {% for key, ktype in Artifactory::Configurable::KEYS %}
      self.{{key.id}} = {{key.id}}.nil? ? Artifactory::Defaults.{{key.id}} : {{key.id}}
      {% end %}
    end

    def [](key)
      {% begin %}
      case key
      {% for key in KEYS %}
      when {{key}}
        {{key.id}}
      {% end %}
      end
    {% end %}
    end

    def self.keys
      KEYS
    end

    # Set the configuration for this config, using a block.
    #
    # Configure the API endpoint
    # ```
    # Artifactory.configure do |config|
    #   config.endpoint = "http://www.my-artifactory-server.com/artifactory"
    # end
    # ```
    def configure
      yield self
    end
  end
end
