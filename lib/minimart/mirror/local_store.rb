module Minimart
  module Mirror
    class LocalStore

      attr_reader :directory_path,
                  :cookbooks

      def initialize(directory_path)
        @directory_path = directory_path
        @cookbooks      = {}

        load_local_inventory
      end

      def add_cookbook_to_store(name, version)
        cookbooks[name] ||= []
        cookbooks[name] << version
      end

      def add_cookbook_from_path(path)
        cookbook = cookbook_from_path(path)
        add_cookbook_to_store(cookbook.metadata.name, cookbook.metadata.version)
        copy_cookbook(cookbook.path, File.join(directory, "/#{cookbook.name}"))
      end

      def installed?(cookbook_name, cookbook_version)
        !!(cookbooks[cookbook_name] &&
          cookbooks[cookbook_name].include?(cookbook_version))
      end

      private

      def copy_cookbook(source, destination)
        FileUtils.rm_rf(destination) if Dir.exists?(destination)
        FileUtils.cp_r(source, destination)

        # clean destination directory
        git_dir = File.join(destination, '/.git')
        FileUtils.rm_rf(git_dir) if Dir.exists?(git_dir)
      end

      def load_local_inventory
        Utils::FileHelper.find_cookbooks_in_directory(directory).each do |path|
          cookbook = cookbook_from_path(path).metadata
          add_cookbook_to_store(cookbook.name, cookbook.version)
        end
      end

      def cookbook_from_path(path)
        path = Utils::FileHelper.cookbook_path_in_directory(path)
        Ridley::Chef::Cookbook.from_path(path)
      end

      def directory
        # lazily create the directory to hold the store
        @directory ||= FileUtils.mkdir_p(directory_path).first
      end

    end
  end
end
