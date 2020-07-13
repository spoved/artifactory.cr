require "uri"
require "json"

module Artifactory
  abstract class Resource::Base
    annotation FieldIgnore; end

    module ClassMethods
      # Get the client (connection) object from the given options. If the
      # +:client+ key is preset in the hash, it is assumed to contain the
      # connection object to use for the request. If the +:client+ key is not
      # present, the default {Artifactory.client} is used.
      #
      # Warning, the value of {Artifactory.client} is **not** threadsafe! If
      # multiple threads or processes are modifying the connection information,
      # the same request _could_ use a different client object. If you use the
      # {Artifactory::Client} proxy methods, this is handled for you.
      #
      # Warning, this method will **remove** the +:client+ key from the hash if
      # it exists.
      #
      # @param [Hash] options
      #   the list of options passed to the method
      #
      # @option options [Artifactory::Client] :client
      #   the client object to use for requests
      #
      def extract_client!(options : Resource::Options = Resource::Options.new) : Artifactory::Client
        # return Artifactory.client unless options[]
        (options.delete(:client) || Artifactory.client).as(Client)
      end

      # Format the repos list from the given options. This method will modify
      # the given Hash parameter!
      #
      # Warning, this method will modify the given hash if it exists.
      #
      # @param [Hash] options
      #   the list of options to extract the repos from
      #
      def format_repos!(**options)
        return options if options[:repos]? || options[:repos].empty?
        options[:repos] = options[:repos].as(Array(String)).compact.join(",")
        options
      end

      # Generate a URL-safe string from the given value.
      #
      # @param [#to_s] value
      #   the value to sanitize
      #
      # @return [String]
      #   the URL-safe version of the string
      #
      def url_safe(value) : String
        URI.encode(URI.decode(value.to_s))
      end

      def form_safe(value) : String
        URI.encode_www_form(URI.decode(value.to_s))
      end

      def from_uri(uri : String, client : Artifactory::Client)
        path = uri.lchop(client.endpoint)
        resp = client.get_raw(path)
        self.from_json(resp.body)
      end

      # Create CGI-escaped string from matrix properties
      #
      # @see http://bit.ly/1qeVYQl
      #
      def to_matrix_properties(hash) : String
        properties = hash.map do |k, v|
          key = form_safe(k.to_s)
          value = form_safe(v.to_s)

          "#{key}=#{value}"
        end

        if properties.empty?
          ""
        else
          ";#{properties.join(";")}"
        end
      end
    end

    extend ClassMethods

    macro inherited
      include JSON::Serializable
    end

    macro base_url(path)
      BASE_URL = {{path}}
    end

    @[FieldIgnore]
    @[JSON::Field(ignore: true)]
    property client : Artifactory::Client = Artifactory.client

    @short_classname : String? = nil

    private def short_classname
      @short_classname ||= self.class.name.split("::").last
    end

    # @see Resource::Base.url_safe
    def url_safe(value)
      self.class.url_safe(value)
    end

    def to_s(io)
      io << "#<"
      io << short_classname
      io << ">"
    end
  end
end
