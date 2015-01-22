require 'minimart/output'

module Minimart
  # General configuration settings for Minimart.
  class Configuration

    class << self
      # IO interface for minimart
      # @return [Minimart::Output]
      def output
        @output || Minimart::Output.new($stdout)
      end

      # Set which IO output should use
      # @param [IO] io
      def output=(io)
        @output = Minimart::Output.new(io)
      end

      def chef_server_config=(config)
        @chef_server = config
      end

      def chef_server_config
        (@chef_server || {})
      end

      def github_config=(config)
        @github_config = config
      end

      def github_config
        (@github_config || {})
      end
    end

  end
end
