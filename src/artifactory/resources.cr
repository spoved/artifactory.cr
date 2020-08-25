module Artifactory
  module Resource
    alias Options = Hash(Symbol, String | Int32 | Bool | Artifactory::Client)
  end
end

require "./resources/*"
