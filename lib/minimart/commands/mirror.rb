module Minimart
  module Commands
    # Mirror is the main entrance point for the mirroring portion of Minimart.
    # Given a directory, and a path to a config file, this class
    # will generate an inventory.
    class Mirror

      # @return [String] The path to the inventory configuration file.
      attr_reader :inventory_config

      # @return [String] The directory to store the inventory.
      attr_reader :inventory_directory


      # @param [Hash] opts
      # @option opts [String] :inventory_directory The directory to store the inventory.
      # @option opts [String] :inventory_config The path to the inventory configuration file.
      def initialize(opts)
        @inventory_directory = opts[:inventory_directory]
        @inventory_config    = Minimart::Mirror::InventoryConfiguration.new(opts[:inventory_config])
      end

      # Generate the inventory.
      def execute!
        builder = Minimart::Mirror::InventoryBuilder.new(inventory_directory, inventory_config)
        builder.build!
      end
    end
  end
end
