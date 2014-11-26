module Minimart
  class Mirror

    attr_reader :inventory_config,
                :inventory_directory

    # options
    #  :inventory_config
    #  :inventory_directory
    def initialize(opts)
      @inventory_directory = opts[:inventory_directory]
      @inventory_config    = Mirror::InventoryConfig.new(opts[:inventory_config])
    end

    def execute!
      builder = InventoryBuilder.new(inventory_directory, inventory_config.parse_sources)
      builder.build!
    end

  end
end
