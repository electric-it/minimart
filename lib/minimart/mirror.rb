require 'minimart/mirror/dependency_graph'
require 'minimart/mirror/inventory_builder'
require 'minimart/mirror/inventory_configuration'
require 'minimart/mirror/local_store'
require 'minimart/mirror/remote_cookbook'
require 'minimart/mirror/source'
require 'minimart/mirror/sources'

module Minimart
  class Mirror

    attr_reader :inventory_config,
                :inventory_directory

    # options
    #  :inventory_config
    #  :inventory_directory
    def initialize(opts)
      @inventory_directory = opts[:inventory_directory]
      @inventory_config    = Mirror::InventoryConfiguration.new(opts[:inventory_config])
    end

    def execute!
      builder = InventoryBuilder.new(inventory_directory, inventory_config)
      builder.build!
    end

  end
end
