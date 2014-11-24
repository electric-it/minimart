module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :inventory_directory,
                  :sources,
                  :local_source

      def initialize(inventory_directory, sources)
        @inventory_directory = inventory_directory
        @sources             = sources
        @local_source        = LocalSource.new(inventory_directory)
      end

      def build!
        make_inventory_directory
        fetch_inventory
      end

      private

      def make_inventory_directory
        Utils::FileHelper.make_directory(inventory_directory)
      end

      def fetch_inventory
        sources.each do |source|
          source.download_explicit_dependencies do |cookbook, archived_cookbook|
            handle_downloaded_cookbook(source, cookbook, archived_cookbook)
          end
        end
      end

      def handle_downloaded_cookbook(source, cookbook, archived_cookbook)
        Utils::Archive.extract_cookbook(archived_cookbook, inventory_destination(cookbook))
        resolve_non_explicit_dependencies(source, cookbook)
      end

      def inventory_destination(cookbook)
        File.join(inventory_directory, "/#{cookbook.name}-#{cookbook.version}")
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
        source.download_cookbook(dependency) do |cookbook, archive_file|
          handle_downloaded_cookbook(source, cookbook, archive_file)
        end

        return dependency
      end
    end

    class UnresolvedDependency < Exception; end
  end
end
