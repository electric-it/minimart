require 'ridley'

module Minimart
  require 'minimart/version'

  require 'minimart/configuration'
  require 'minimart/error'
  require 'minimart/mirror'

  require 'minimart/download/git_repository'
  require 'minimart/download/supermarket'

  require 'minimart/utils/archive'
  require 'minimart/utils/file_helper'
  require 'minimart/utils/http'

  require 'minimart/inventory_requirement/base_requirement'
  require 'minimart/inventory_requirement/git_requirement'
  require 'minimart/inventory_requirement/local_path_requirement'
end
