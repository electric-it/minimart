module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :inventory_directory,
                  :sources
                  :local_source

      def initialize(inventory_directory, sources)
        @inventory_directory = inventory_directory
        @sources             = sources
      end

      def build!
        make_inventory_directory
        fetch_explicit_sources
        fetch_inventory
      end

      private

      def make_inventory_directory
        Utils::FileHelper.make_directory(inventory_directory)
      end

      def fetch_explicit_sources
        sources.with_location_specifications.each do |source|
          source.download_cookbooks(inventory_directory) do |cookbook|
            handle_downloaded_cookbook(source, cookbook)
          end
        end
      end

      def fetch_inventory
        sources.with_supermarket_specifications.each do |source|
          source.download_cookbooks(inventory_directory) do |cookbook|
            handle_downloaded_cookbook(source, cookbook)
          end
        end
      end

      def handle_downloaded_cookbook(source, cookbook)
        resolve_non_explicit_dependencies(source, cookbook)
      end

      def resolve_non_explicit_dependencies(current_source, cookbook)
        return if cookbook.dependencies.nil? || cookbook.dependencies.empty?

        cookbook.dependencies.each do |name, requirements|
          return if download_cookbook_for_source(current_source, name, requirements)

          sources.each do |source|
            return if download_cookbook_for_source(source, name, requirements)
          end

          raise UnresolvedDependency
        end
      end

      def download_cookbook_for_source(source, name, requirements)
        return if (dependency_version = source.resolve_dependency(name, requirements)).nil?

        dependency = Hashie::Mash.new(name: name, version: dependency_version)
        source.download_cookbook(dependency, inventory_directory) do |cookbook|
          handle_downloaded_cookbook(source, cookbook)
        end

        return dependency
      end
    end

    class UnresolvedDependency < Exception; end
  end
end
