module Minimart
  class Configuration

    DEFAULT_INVENTORY_CONFIG    = './inventory.yml'
    DEFAULT_INVENTORY_DIRECTORY = './inventory'

    class << self
      def output
        @output || $stdout
      end

      def output=(io)
        @output = io
      end
    end
  end
end
