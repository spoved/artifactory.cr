# artifactory [![Build Status](https://travis-ci.com/spoved/artifactory.cr.svg?token=Shp7EsY9qyrwFK1NgezB&branch=master)](https://travis-ci.com/spoved/artifactory.cr)

A BETA crystal implementation of [artifactory-client](https://github.com/chef/artifactory-client)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     artifactory:
       github: kalinon/artifactory.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "artifactory"
```

### Create a connection

Before you can make a request, you must give Artifactory your connection information.

```crystal
Artifactory.configure do |config|
  # The endpoint for the Artifactory server. If you are running the "default"
  # Artifactory installation using tomcat, don't forget to include the
  # +/artifactoy+ part of the URL.
  config.endpoint = 'https://my.storage.server/artifactory'

  # The basic authentication information. Since this uses HTTP Basic Auth, it
  # is highly recommended that you run Artifactory over SSL.
  config.username = 'admin'
  config.password = 'password'

  # You can also use an API key for authentication, username and password
  # take precedence so leave them off if you are using an API key.
  config.api_key = 'XXXXXXXXXXXXXXXXXX'

  # You can also use an API Access Token for authentication. This will be 
  # added to request headers as the Bearer token.
  config.access_token = "aaaa.bbbb.cccc"

  # Speaking of SSL, you can specify the path to a pem file with your custom
  # certificates and the gem will wire it all up for you (NOTE: it must be a
  # valid PEM file).
  config.ssl_pem_file = '/path/to/my.pem'

  # Or if you are feelying frisky, you can always disable SSL verification
  config.ssl_verify = false
end
```

Or, if you want to be really Unixy, these parameters are all configurable via environment variables:

```bash
# Artifactory will use these values for the defaults
export ARTIFACTORY_ENDPOINT=http://my.storage.server/artifactory
export ARTIFACTORY_USERNAME=admin
export ARTIFACTORY_PASSWORD=password
export ARTIFACTORY_API_KEY=XXXXXXXXXXXXXXXXXX
export ARTIFACTORY_ACCESS_TOKEN=aaaa.bbbb.cccc
export ARTIFACTORY_SSL_PEM_FILE=/path/to/my.pem
```

### Making requests

#### Artifacts

```crystal
# Upload an artifact to a repository whose key is 'repo_key'
artifact.upload('/local/path/to/file', 'repo_key', param_1: 'foo')

# Search for an artifact by name
artifact = Artifact.search(name: 'package.deb').first
artifact #=> "#<Artifactory::Resource::Artifact md5: 'ABCD1234'>"

# Get the properties of an artifact
artifact.md5 #=> "ABCD1234"
artifact.properties #=> { ... }
# Set the properties of an artifact
artifact.properties({prop1: 'value1', 'prop2': 'value2'}) #=> { ... }

# Delete the artifact from the Artifactory server
artifact.delete #=> true
```

## Contributing

1. Fork it (<https://github.com/spoved/artifactory.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Holden Omans](https://github.com/kalinon) - creator and maintainer
