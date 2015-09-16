module Minimart
  module Commands
    # Mirror is the main entrance point for the mirroring portion of Minimart.
    # Given a directory, and a path to a config file, this class
    # will generate an inventory.
    class Mirror

      attr_reader :inventory_config, :inventory_directory, :load_deps

      # @param [Hash] opts
      # @option opts [String] :inventory_directory The directory to store the inventory.
      # @option opts [String] :inventory_config The path to the inventory configuration file.
      def initialize(opts)
        @inventory_directory = opts[:inventory_directory]
        Minimart::Configuration.load_deps = opts[:load_deps] if opts[:load_deps]
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
