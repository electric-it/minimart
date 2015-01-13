module Minimart
  class Configuration

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
