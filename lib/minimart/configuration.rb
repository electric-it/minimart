module Minimart
  class Configuration

    DEFAULT_INVENTORY_CONFIG    = './inventory.yml'
    DEFAULT_INVENTORY_DIRECTORY = './inventory'

    class << self
      def output
        $stdout
      end
    end
  end
end
