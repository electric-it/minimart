module Minimart
  module InventoryRequirement

    # BaseRequirement represents a single cookbook entry as listed in the inventory.
    # BaseRequirement is a generic interface for other inventory requirements.
    class BaseRequirement

      attr_reader :name, :version_requirement, :cookbook

      # @param [String] name The name of the cookbook
      # @param [Hash] opts
      # @option opts [String] :version_requirement The SemVer requirement for the cookbook
      def initialize(name, opts)
        @name = name.to_s
        @version_requirement = opts[:version_requirement]
      end

      # Determine whether or not this is a requirement which explicitly defines
      # it's location (e.g. Git repo). Defaults to FALSE.
      # @return [Boolean]
      def explicit_location?
        false
      end

      # The requirements to download this cookbook.
      # @return [Hash]
      def requirements
        # if this cookbook has it's location specified, we instead return it's
        # dependencies as we don't need to resolve them elsewhere

        if load_dependencies?
          explicit_location? ? cookbook.dependencies : { name => version_requirement }
        else
          explicit_location? ? {} : { name => version_requirement }
        end
      end

      def load_dependencies?
        Minimart::Configuration.load_deps
      end

      # Download a cookbook that has it's location explicitly defined (see #explicit_location?)
      # @yield [Minimart::Cookbook]
      def fetch_cookbook(&block)
        return unless explicit_location?

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
        {
            :metadata_version => '2.0', #metadata document version.
            :name => @name
        }
      end

      # Determine if a cookbook in the inventory has metadata matching this requirement
      # @param [Minimart::Mirror::DownloadMetadata] metadata The download metadata for a cookbook
      #   in the inventory.
      # @return [Boolean] Defaults to true
      def matching_source?(metadata)
        if metadata.has_key?('metadata_version') && metadata['metadata_version'] == '2.0'
          metadata['name'] == @name &&
            metadata['version'] == @version_requirement
        else
          true
        end
      end

      private

      # This method must be overridden by any subclasses.
      def download_cookbook(&block)
        nil
      end

    end
  end
end
