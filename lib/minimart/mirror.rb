require 'minimart/mirror/dependency_graph'
require 'minimart/mirror/inventory_builder'
require 'minimart/mirror/inventory_configuration'
require 'minimart/mirror/local_store'
require 'minimart/mirror/remote_cookbook'
require 'minimart/mirror/source'
require 'minimart/mirror/sources'

module Minimart
  # Mirror is the main entrance point for the mirroring portion of Minimart.
  # Given a directory, and a path to a config file, this class
  # will generate an inventory.
  class Mirror

    attr_reader :inventory_config,
                :inventory_directory


    # @param [Hash] opts
    # @option opts [String] :inventory_directory The directory to store the inventory.
    # @option opts [String] :inventory_config The path to the inventory configuration file.
    def initialize(opts)
      @inventory_directory = opts[:inventory_directory]
      @inventory_config    = Mirror::InventoryConfiguration.new(opts[:inventory_config])
    end

    # Generate the inventory.
    def execute!
      builder = InventoryBuilder.new(inventory_directory, inventory_config)
      builder.build!
    end

  end
end
