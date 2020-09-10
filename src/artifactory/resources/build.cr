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
    property build_type : String?
    # Build tool information
    @[JSON::Field(key: "buildAgent")]
    property build_agent : Build::Agent?
    # CI Server information
    property agent : Build::Agent?
    @[JSON::Field(key: "artifactoryPluginVersion")]
    property artifactory_plugin_version : String?
    @[JSON::Field(key: "durationMillis")]
    property duration_millis : Int32?
    @[JSON::Field(key: "artifactoryPrincipal")]
    property artifactory_principal : String?
    property url : String?
    @[JSON::Field(key: "vcsRevision")]
    property vcs_revision : String?
    @[JSON::Field(key: "vcsUrl")]
    property vcs_url : String?
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

      property name : String?
      property version : String?
    end

    class BuildRetention
      include JSON::Serializable

      @[JSON::Field(key: "deleteBuildArtifacts")]
      property delete_build_artifacts : Bool?
      property count : Int32?
      @[JSON::Field(key: "minimumBuildDate")]
      property minimum_build_date : Int32?
      @[JSON::Field(key: "buildNumbersNotToBeDiscarded")]
      property build_numbers_not_to_be_discarded : Array(JSON::Any?)?
    end

    class Issues
      include JSON::Serializable

      property tracker : Agent?
      @[JSON::Field(key: "aggregateBuildIssues")]
      property aggregate_build_issues : Bool?
      @[JSON::Field(key: "aggregationBuildStatus")]
      property aggregation_build_status : String?
      @[JSON::Field(key: "affectedIssues")]
      property affected_issues : Array(AffectedIssue) = Array(AffectedIssue).new
    end

    class AffectedIssue
      include JSON::Serializable

      property key : String?
      property url : String?
      property summary : String?
      property aggregated : Bool?
    end

    class LicenseControl
      include JSON::Serializable

      @[JSON::Field(key: "runChecks")]
      property run_checks : Bool?
      @[JSON::Field(key: "includePublishedArtifacts")]
      property include_published_artifacts : Bool?
      @[JSON::Field(key: "autoDiscover")]
      property auto_discover : Bool?
      @[JSON::Field(key: "scopesList")]
      property scopes_list : String?
      @[JSON::Field(key: "licenseViolationsRecipientsList")]
      property license_violations_recipients_list : String?
    end

    class Module
      include JSON::Serializable

      property properties : Hash(String, String) = Hash(String, String).new
      property id : String?
      property artifacts : Array(Artifact) = Array(Artifact).new
      property dependencies : Array(Dependency) = Array(Dependency).new
    end

    class Artifact
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property artifact_type : String?
      property sha1 : String?
      property md5 : String?
      property name : String?
    end

    class Dependency
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property dependency_type : String?
      property sha1 : String?
      property md5 : String?
      property id : String?
      property scopes : Array(String) = Array(String).new
    end
  end
end
