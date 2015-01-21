module Minimart
  module InventoryRequirement

    # BaseRequirement represents a single cookbook entry as listed in the inventory.
    # BaseRequirement is a generic interface for other inventory requirements.
    class BaseRequirement

      # @return [String] The name of the cookbook
      attr_reader :name

      # @return [String] The SemVer requirement for the cookbook
      attr_reader :version_requirement

      # @return [Minimart::Cookbook] The resolved cookbook
      attr_reader :cookbook

      # @param [String] name The name of the cookbook
      # @param [Hash] opts
      # @option opts [String] :version_requirement The SemVer requirement for the cookbook
      def initialize(name, opts)
        @name = name
        @version_requirement = opts[:version_requirement]
      end

      # Determine whether or not this is a requirement which explicitly defines
      # it's location (e.g. Git repo). Defaults to FALSE.
      # @return [Boolean]
      def location_specification?
        false
      end

      # The requirements to download this cookbook.
      # @return [Hash]
      def requirements
        # if this cookbook has it's location specified, we instead return it's
        # dependencies as we don't need to resolve them elsewhere
        location_specification? ? cookbook.dependencies : {name => version_requirement}
      end

      # Download a cookbook that has it's location explicitly defined (see #location_specification?)
      # @yield [Minimart::Cookbook]
      def fetch_cookbook(&block)
        return unless location_specification?

        download_cookbook do |cookbook|
          @cookbook = cookbook
          block.call(cookbook) if block
        end
      end

      # Determine whether or not a version requirement was defined for the given
      # cookbook.
      # @return [Boolean]
      def version_requirement?
        !!version_requirement
      end

      # Convert the requirement to a Hash.
      # @return [Hash]
      def to_hash
        {}
      end

      private

      # This method must be overridden by any subclasses.
      def download_cookbook(&block)
        nil
      end

    end
  end
end
