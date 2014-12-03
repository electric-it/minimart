require 'hashie'
require 'ridley'

module Minimart
  require 'minimart/version'

  require 'minimart/configuration'
  require 'minimart/mirror'

  require 'minimart/download/git_repository'
  require 'minimart/download/supermarket'

  require 'minimart/utils/archive'
  require 'minimart/utils/file_helper'
  require 'minimart/utils/hash_with_indifferent_access'
  require 'minimart/utils/http'

  require 'minimart/inventory_cookbook/base_cookbook'
  require 'minimart/inventory_cookbook/git_cookbook'
  require 'minimart/inventory_cookbook/local_cookbook'
end
