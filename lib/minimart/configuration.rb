require 'minimart/output'

module Minimart
  class Configuration

    class << self
      def output
        @output || Minimart::Output.new($stdout)
      end

      def output=(io)
        @output = Minimart::Output.new(io)
      end
    end
  end
end
