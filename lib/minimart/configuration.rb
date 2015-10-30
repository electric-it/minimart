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

      def load_deps=(load_deps)
        @load_deps = load_deps
      end

      def load_deps
        if defined? @load_deps
          @load_deps
        else
          true
        end
      end

      def chef_server_config=(config)
        @chef_server = config
      end

      def chef_server_config
        (@chef_server || {}).merge(ssl: {verify: verify_ssl})
      end

      def github_config=(config)
        @github_config = config
      end

      def github_config
        (@github_config || {}).merge(connection_options: {ssl: {verify: verify_ssl}})
      end

      def verify_ssl
        @verify_ssl.nil? ? true : @verify_ssl
      end

      def verify_ssl=(val)
        @verify_ssl = val
      end
    end

  end
end
