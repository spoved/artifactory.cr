require "./base"

module Artifactory
  class Resource::Repository < Resource::Base
    base_url "artifactory/api/repositories"

    module ClassMethods
      # Get a list of all repositories in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @return [Array<Resource::Repository>]
      #   the list of builds
      #
      def all(options : Resource::Options = Resource::Options.new)
        client = extract_client!(options)
        resp = client.get(BASE_URL)
        resp.as_a.map do |hash|
          find(hash["key"], {:client => client})
        end.compact
      end

      # Find (fetch) a repository by name.
      #
      # @example Find a repository by named key
      #   Repository.find(name: 'libs-release-local') #=> #<Resource::Artifact>
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [String] :name
      #   the name of the repository to find
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::Repository, nil]
      #   an instance of the repository that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options : Resource::Options = Resource::Options.new)
        client = extract_client!(options)
        client.get("#{BASE_URL}/#{url_safe(name)}", klass: Resource::Repository)
      rescue ex : Spoved::Api::Error
        # Log.error { ex }
        nil
      end
    end

    extend ClassMethods

    property key : String
    property description : String = ""
    property notes : String = "Some internal notes"
    property rclass : String = "local"

    # - "debianTrivialLayout" : false,
    # - "xrayIndex" : false (default),
    # - "archiveBrowsingEnabled" : false,
    # - "dockerApiVersion" : "V2" (default),
    # - "enableFileListsIndexing" : "false" (default),
    # - "optionalIndexCompressionFormats" : ["bz2", "lzma", "xz"],
    # - "downloadRedirect" : "false" (default),
    # - "cdnRedirect": "false" (default, Applies to Artifactory Cloud Only),
    # - "blockPushingSchema1": "false",
    # - "keyPairRef": "pairName"

    @[JSON::Field(key: "blackedOut")]
    property blacked_out : Bool = false
    @[JSON::Field(key: "checksumPolicyType")]
    property checksum_policy_type : String = "client-checksums"
    @[JSON::Field(key: "excludesPattern")]
    property excludes_pattern : String = ""
    @[JSON::Field(key: "handleReleases")]
    property handle_releases : Bool = true
    @[JSON::Field(key: "handleSnapshots")]
    property handle_snapshots : Bool = true
    @[JSON::Field(key: "includesPattern")]
    property includes_pattern : String = "**/*"
    @[JSON::Field(key: "maxUniqueSnapshots")]
    property max_unique_snapshots : Int32 = 0
    @[JSON::Field(key: "maxUniqueTags")]
    property max_unique_tags : Int32 = 0
    @[JSON::Field(key: "packageType")]
    property package_type : String = "generic"
    @[JSON::Field(key: "repoLayoutRef")]
    property repo_layout_ref : String = "simple-default"
    @[JSON::Field(key: "snapshotVersionBehavior")]
    property snapshot_version_behavior : String = "non-unique"
    @[JSON::Field(key: "suppressPomConsistencyChecks")]
    property suppress_pom_consistency_checks : Bool = false
    @[JSON::Field(key: "yumRootDepth")]
    property yum_root_depth : Int32 = 0
    @[JSON::Field(key: "calculateYumMetadata")]
    property calculate_yum_metadata : Bool = false

    @[JSON::Field(key: "propertySets")]
    property property_sets : Array(String) = [] of String

    # @[JSON::Field(key: "excludesPattern")]
    # property external_dependencies_enabled : Bool = false
    # @[JSON::Field(key: "excludesPattern")]
    # property client_tls_certificate : String = ""

    # property repositories = []

    def initialize(@key : String, @description = "", @notes = "")
    end

    # The path to this repository on the server.
    def api_path : String
      "#{BASE_URL}/#{url_safe(key)}"
    end

    # Delete this repository from artifactory, suppressing any +ResourceNotFound+
    # exceptions might occur.
    def delete
      client.delete(api_path).success?
    end

    # Creates or updates a repository configuration depending on if the
    # repository configuration previously existed. This method also works
    # around Artifactory's dangerous default behavior:
    #
    #   > An existing repository with the same key are removed from the
    #   > configuration and its content is removed!
    def save
      if self.class.find(key, {:client => client})
        client.post_raw(api_path, to_json, extra_headers: headers).success?
      else
        client.put_raw(api_path, to_json, extra_headers: headers).success?
      end
      true
    end

    # The default Content-Type for this repository. It varies based on the
    # repository type.
    def content_type
      case rclass.to_s.downcase
      when "local"
        "application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json"
      when "remote"
        "application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json"
      when "virtual"
        "application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json"
      else
        raise "Unknown Repository type `#{rclass}'!"
      end
    end

    @[JSON::Field(ignore: true)]
    @headers : Hash(String, String)? = nil

    # The default headers for this object. This includes the +Content-Type+.
    def headers
      @headers ||= {
        "Content-Type" => content_type,
      }
    end
  end
end
