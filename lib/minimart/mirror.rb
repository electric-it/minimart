module Minimart
  class Mirror

    attr_reader :inventory

    def initialize(options)
      @inventory = Minimart::Mirror::Inventory.new(options)
    end

    def execute!
      inventory.build
    end

  end
end
