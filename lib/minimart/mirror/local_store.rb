require 'minimart/mirror/download_metadata'

module Minimart
  module Mirror

    # The LocalStore manages what is stored in the local inventory, and adding
    # cookbook directories to the local inventory. The LocalStore will automatically
    # load anything that has been stored in the inventory upon initialization.
    class LocalStore

      # @return [String] the path to the local inventory
      attr_reader :directory_path

      # @param [String] directory_path The path to the local inventory
      def initialize(directory_path)
        @directory_path = directory_path
        @cookbooks      = {}

        load_local_inventory
      end

      # :nodoc:
      def add_cookbook_to_store(name, version)
        cookbooks[name] ||= []
        cookbooks[name] << version
      end

      # Copy a given cookbook to the local store, and record any metadata
      # about how the cookbook was downloaded.
      # @param [String] path The path to the cookbook to add to the store
      # @param [Hash] download_data Any data to record about the cookbook in a Minimart metadata file.
      def add_cookbook_from_path(path, download_data = {})
        cookbook_from_path(path).tap do |cookbook|
          add_cookbook_to_store(cookbook.name, cookbook.version)
          copy_cookbook(cookbook.path, local_path_for(cookbook))
          write_download_data(cookbook, download_data)
        end
      end

      # Determine whether or not a cookbook has been added to the LocalStore
      # @return [Boolean]
      def installed?(cookbook_name, cookbook_version)
        !!(cookbooks[cookbook_name] &&
          cookbooks[cookbook_name].include?(cookbook_version))
      end

      private

      attr_reader :cookbooks

      def copy_cookbook(source, destination)
        FileUtils.rm_rf(destination) if Dir.exists?(destination)
        FileUtils.cp_r(source, destination)

        # clean destination directory
        git_dir = File.join(destination, '/.git')
        FileUtils.rm_rf(git_dir) if Dir.exists?(git_dir)
      end

      def load_local_inventory
        Utils::FileHelper.find_cookbooks_in_directory(directory).each do |path|
          cookbook = cookbook_from_path(path)
          add_cookbook_to_store(cookbook.name, cookbook.version)
        end
      end

      def cookbook_from_path(path)
        Minimart::Cookbook.from_path(Utils::FileHelper.cookbook_path_in_directory(path))
      end

      def directory
        # lazily create the directory to hold the store
        @directory ||= FileUtils.mkdir_p(directory_path).first
      end

      def local_path_for(cookbook)
        File.join(directory, "/#{cookbook}")
      end

      def write_download_data(cookbook, download_data = {})
        Minimart::Mirror::DownloadMetadata.new(local_path_for(cookbook)).write(download_data)
      end

    end
  end
end
