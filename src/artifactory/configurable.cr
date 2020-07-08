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

    def self.keys
      KEYS
    end

    {% begin %}
      {% for key, ktype in Artifactory::Configurable::KEYS %}
        property {{key.id}} : {{ktype}}? = nil
      {% end %}

      alias Options=Hash(Symbol, Union({{*Artifactory::Configurable::KEYS.values}}, Nil))
    {% end %}

    macro included

      def initializ(options : Artifactory::Configurable::Options? = nil)
        {% for key, ktype in Artifactory::Configurable::KEYS %}
        self.{{key.id}} = options[{{key}}]? || Artifactory::Defaults.{{key.id}}
        {% end %}
      end

      def initialize(
        {% for key, ktype in Artifactory::Configurable::KEYS %}
          @{{key.id}} : {{ktype}}? = nil,
        {% end %}
      )
        {% for key, ktype in Artifactory::Configurable::KEYS %}
        self.{{key.id}} = Artifactory::Defaults.{{key.id}} if {{key.id}}.nil?
        {% end %}
      end

      def options : Options
        {% begin %}
        {
          {% for key in Configurable::KEYS %}
          {{key}} => {{key.id}},
          {% end %}
        }
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
