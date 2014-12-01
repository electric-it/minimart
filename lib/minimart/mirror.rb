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
      builder = InventoryBuilder.new(inventory_directory, inventory_config.sources, inventory_config.cookbooks)
      builder.build!
    end

  end
end
