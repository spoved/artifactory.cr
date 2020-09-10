require "./base"

module Artifactory
  @[JSON::Serializable::Options(emit_nulls: false)]
  # See https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-BuildUpload
  class Resource::Build < Resource::Base
    base_url "artifactory/api/build"

    include JSON::Serializable

    module ClassMethods
    end

    extend ClassMethods

    property properties : Hash(String, String) = Hash(String, String).new
    property version : String
    property name : String
    property number : String

    # Build start time in the format of yyyy-MM-dd'T'HH:mm:ss.SSSZ
    property started : String

    # MAVEN, GRADLE, ANT, IVY and GENERIC
    @[JSON::Field(key: "type")]
    property build_type : String? = nil
    # Build tool information
    @[JSON::Field(key: "buildAgent")]
    property build_agent : Build::Agent? = nil
    # CI Server information
    property agent : Build::Agent? = nil
    @[JSON::Field(key: "artifactoryPluginVersion")]
    property artifactory_plugin_version : String? = nil
    @[JSON::Field(key: "durationMillis")]
    property duration_millis : Int32? = nil
    @[JSON::Field(key: "artifactoryPrincipal")]
    property artifactory_principal : String? = nil
    property url : String? = nil
    @[JSON::Field(key: "vcsRevision")]
    property vcs_revision : String? = nil
    @[JSON::Field(key: "vcsUrl")]
    property vcs_url : String? = nil
    @[JSON::Field(key: "licenseControl")]
    property license_control : Build::LicenseControl = Build::LicenseControl.new
    @[JSON::Field(key: "buildRetention")]
    property build_retention : Build::BuildRetention = Build::BuildRetention.new
    property modules : Array(Module) = Array(Module).new
    property issues : Build::Issues = Build::Issues.new

    def initialize(@name, @version, @number, @started)
    end

    def upload
    end

    class Agent
      include JSON::Serializable

      property name : String? = nil
      property version : String? = nil
      def initialize; end
    end

    class BuildRetention
      include JSON::Serializable

      @[JSON::Field(key: "deleteBuildArtifacts")]
      property delete_build_artifacts : Bool? = nil
      property count : Int32? = nil
      @[JSON::Field(key: "minimumBuildDate")]
      property minimum_build_date : Int32? = nil
      @[JSON::Field(key: "buildNumbersNotToBeDiscarded")]
      property build_numbers_not_to_be_discarded : Array(JSON::Any?)? = nil

      def initialize; end
    end

    class Issues
      include JSON::Serializable

      property tracker : Agent? = nil
      @[JSON::Field(key: "aggregateBuildIssues")]
      property aggregate_build_issues : Bool? = nil
      @[JSON::Field(key: "aggregationBuildStatus")]
      property aggregation_build_status : String? = nil
      @[JSON::Field(key: "affectedIssues")]
      property affected_issues : Array(AffectedIssue) = Array(AffectedIssue).new
      def initialize; end
    end

    class AffectedIssue
      include JSON::Serializable

      property key : String? = nil
      property url : String? = nil
      property summary : String? = nil
      property aggregated : Bool? = nil

      def initialize; end
    end

    class LicenseControl
      include JSON::Serializable

      @[JSON::Field(key: "runChecks")]
      property run_checks : Bool? = nil
      @[JSON::Field(key: "includePublishedArtifacts")]
      property include_published_artifacts : Bool? = nil
      @[JSON::Field(key: "autoDiscover")]
      property auto_discover : Bool? = nil
      @[JSON::Field(key: "scopesList")]
      property scopes_list : String? = nil
      @[JSON::Field(key: "licenseViolationsRecipientsList")]
      property license_violations_recipients_list : String? = nil

      def initialize; end
    end

    class Module
      include JSON::Serializable

      property properties : Hash(String, String) = Hash(String, String).new
      property id : String? = nil
      property artifacts : Array(Artifact) = Array(Artifact).new
      property dependencies : Array(Dependency) = Array(Dependency).new

      def initialize; end
    end

    class Artifact
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property artifact_type : String? = nil
      property sha1 : String? = nil
      property md5 : String? = nil
      property name : String? = nil
      def initialize; end
    end

    class Dependency
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property dependency_type : String? = nil
      property sha1 : String? = nil
      property md5 : String? = nil
      property id : String? = nil
      property scopes : Array(String) = Array(String).new
      def initialize; end
    end
  end
end
