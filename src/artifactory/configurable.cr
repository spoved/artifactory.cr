module Artifactory
  module Configurable
    KEYS = {
      :endpoint     => String,
      :username     => String?,
      :password     => String?,
      :api_key      => String?,
      :access_token => String?,
      :ssl_verify   => Bool,
      :ssl_pem_file => String?,
      :read_timeout => Int32,

      # :proxy_address  => String?,
      # :proxy_password => String?,
      # :proxy_port     => Int32?,
      # :proxy_username => String?,
      # :user_agent     => String,
    }

    def self.keys
      KEYS
    end

    {% begin %}
      {% for key, ktype in Artifactory::Configurable::KEYS %}
        property {{key.id}} : {{ktype}}
      {% end %}

      alias Options=Hash(Symbol, Union({{*Artifactory::Configurable::KEYS.values}}, Nil))
    {% end %}

    macro included
      def initialize(options : Artifactory::Configurable::Options = Artifactory::Configurable::Options.new, **args)
        {% for key, ktype in Artifactory::Configurable::KEYS %}
        @{{key.id}} = if options[{{key}}]?
                            options[{{key}}].as({{ktype.id}})
                          elsif args[{{key}}]?
                            args[{{key}}]?.not_nil!
                          else
                            Artifactory::Defaults.{{key.id}}
                          end
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

    def []?(key)
      {% begin %}
      case key
      {% for key in KEYS %}
      when {{key}}
        {{key.id}}
      {% end %}
      else
        nil
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
