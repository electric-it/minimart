module Minimart
  # The Mirror namespace is used to build the local cookbook inventory.
  module Mirror
    require 'minimart/mirror/dependency_graph'
    require 'minimart/mirror/inventory_builder'
    require 'minimart/mirror/inventory_configuration'
    require 'minimart/mirror/local_store'
    require 'minimart/mirror/source_cookbook'
    require 'minimart/mirror/source'
    require 'minimart/mirror/sources'
  end
end
