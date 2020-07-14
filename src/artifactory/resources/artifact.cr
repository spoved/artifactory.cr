require "./base"
require "digest/sha1"
require "digest/md5"

module Artifactory
  @[JSON::Serializable::Options(emit_nulls: false)]
  class Resource::Artifact < Resource::Base
    SEARCH_URL      = "artifactory/api/search/artifact"
    PROP_SEARCH_URL = "artifactory/api/search/prop"

    module ClassMethods
      def search(name : String, *repos,
                 client : Artifactory::Client? = nil)
        c = client || Artifactory.client
        resp = c.get(SEARCH_URL, {"name" => name, "repos" => repos.join(",")})
        resp["results"].as_a.map do |artifact|
          from_uri(artifact["uri"].as_s, client: c)
        end.compact
      end

      def search(*repos, client : Artifactory::Client? = nil, **props)
        c = client || Artifactory.client
        props_hash = props.to_h.merge({"repos" => repos.join(",")}).transform_keys { |k| k.to_s }
        resp = c.get(PROP_SEARCH_URL, props_hash)
        resp["results"].as_a.map do |artifact|
          from_uri(artifact["uri"].as_s, client: c)
        end.compact
      end
    end

    extend ClassMethods

    @[JSON::Field(emit_null: false)]
    property uri : String? = nil

    property repo : String
    property size : String
    property path : String

    @[JSON::Field(key: "downloadUri")]
    property download_uri : String? = nil
    @[JSON::Field(key: "mimeType")]
    property mime_type : String? = nil

    property checksums : Hash(String, String) = Hash(String, String).new
    @[JSON::Field(key: "originalChecksums")]
    property original_checksums : Hash(String, String) = Hash(String, String).new

    property created : Time? = nil
    @[JSON::Field(key: "createdBy")]
    property created_by : String? = nil
    @[JSON::Field(key: "lastUpdated")]
    property last_updated : Time? = nil
    @[JSON::Field(key: "lastModified")]
    property last_modified : Time? = nil
    @[JSON::Field(key: "modifiedBy")]
    property modified_by : String? = nil

    @[JSON::Field(ignore: true)]
    property local_path : String? = nil
    @[JSON::Field(ignore: true)]
    @relative_path : String? = nil
    @[JSON::Field(ignore: true)]
    @properties : Hash(String, JSON::Any)? = nil

    def initialize(@repo : String, @path : String, local_path : String)
      if !local_path.nil? && File.exists?(local_path)
        @local_path = local_path
        @size = File.size(local_path).to_s
      else
        raise Exception.new "You must include the local path"
      end
    end

    # The SHA of this artifact.
    def sha1
      checksums["sha1"]?
    end

    # The MD5 of this artifact.
    def md5
      checksums["md5"]?
    end

    # Helper method for extracting the relative (repo) path, since it's not
    # returned as part of the API.
    #
    # @example Get the relative URI from the resource
    #   /libs-release-local/org/acme/artifact.deb
    #
    # @return [String]
    #
    def relative_path
      @relative_path ||= uri.not_nil!.split("api/storage", 2).last
    end

    # Delete this artifact from repository, suppressing any +ResourceNotFound+
    # exceptions might occur.
    def delete
      client.delete(File.join("artifactory", relative_path)).success?
    end

    # Copy or move current artifact to a new destination.
    #
    # @example Move the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    # @example Copy the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    #
    # @param [Symbol] action
    #   the action (+:move+ or +:copy+)
    # @param [String] destination
    #   the server-side destination to move or copy the artifact
    # @param [Hash] options
    #   the list of options to pass
    #
    # @option options [Boolean] :fail_fast (default: +false+)
    #   fail on the first failure
    # @option options [Boolean] :suppress_layouts (default: +false+)
    #   suppress cross-layout module path translation during copying or moving
    # @option options [Boolean] :dry_run (default: +false+)
    #   pretend to do the copy or move
    #
    # @return [Hash]
    #   the parsed JSON response from the server
    #
    def copy_or_move(action, destination, **options)
      params = Hash(String, String).new.tap do |param|
        param["to"] = destination
        param["failFast"] = 1 if options[:fail_fast]?
        param["suppressLayouts"] = 1 if options[:suppress_layouts]?
        param["dry"] = 1 if options[:dry_run]?
      end

      endpoint = File.join("artifactory/api", action.to_s, relative_path)

      client.post(endpoint, params)
    end

    # See #copy_or_move
    def copy(destination, **options)
      copy_or_move(:copy, destination, **options)
    end

    # See #copy_or_move
    def move(destination, **options)
      copy_or_move(:move, destination, **options)
    end

    # Upload an artifact into the repository. If the first parameter is a File
    # object, that file descriptor is passed to the uploader. If the first
    # parameter is a string, it is assumed to be the path to a local file on
    # disk. This method will automatically construct the File object from the
    # given path.
    #
    # @see bit.ly/1dhJRMO Artifactory Matrix Properties
    #
    # @example Upload an artifact from a File instance
    #   artifact = Artifact.new(local_path: '/local/path/to/file.deb')
    #   artifact.upload('libs-release-local', '/remote/path')
    #
    # @example Upload an artifact with matrix properties
    #   artifact = Artifact.new(local_path: '/local/path/to/file.deb')
    #   artifact.upload('libs-release-local', "/remote/path",
    #     status: 'DEV',
    #     rating: 5,
    #     branch: 'master'
    #   )
    #
    # @param [String] repo
    #   the key of the repository to which to upload the file
    # @param [String] remote_path
    #   the path where this resource will live in the remote artifactory
    #   repository, relative to the repository key
    # @param [Hash] headers
    #   the list of headers to send with the request
    # @param [Hash] properties
    #   a list of matrix properties
    def upload(repo : String? = nil, remote_path : String? = nil, headers : Hash(String, String) = Hash(String, String).new, **props)
      upload_repo = repo || self.repo
      upload_path = remote_path || path

      file = File.new(File.expand_path(local_path.not_nil!))
      matrix = self.class.to_matrix_properties(props.to_h)
      endpoint = File.join("artifactory", url_safe(upload_repo), upload_path) + matrix

      # Include checksums in headers if given.
      contents = File.read(file.path)

      headers["X-Checksum-Md5"] = md5.nil? ? Digest::MD5.hexdigest(contents) : md5.not_nil!
      headers["X-Checksum-Sha1"] = sha1.nil? ? Digest::SHA1.hexdigest(contents) : sha1.not_nil!

      response = client.put_file(endpoint, file, extra_headers: headers)
      return nil unless response.success?

      {{@type}}.from_json(response.body)
    end

    # GET /api/storage/libs-release-local/org/acme?properties\[=x[,y]\]
    # {
    # "uri": "http://localhost:8081/artifactory/api/storage/libs-release-local/org/acme"
    # "properties":{
    #         "p1": ["v1","v2","v3"],
    #         "p2": ["v4","v5","v6"]
    #     }
    # }
    def properties : Hash(String, JSON::Any)
      @properties ||= fetch_properties
    end

    private def fetch_properties
      endpoint = File.join("artifactory/api/storage", relative_path)
      response = client.get(endpoint, {"properties" => ""})
      if response["properties"]?
        response["properties"].as_h
      else
        Hash(String, JSON::Any).new
      end
    end

    def get_contents
      endpoint = download_uri.not_nil!.split("artifactory", 2).last
      client.get_raw(path: "artifactory" + endpoint)
    end
  end
end
