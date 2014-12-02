module Minimart
  class Mirror
    class LocalStore

      attr_reader :directory,
                  :cookbooks

      def initialize(directory)
        @directory = directory
        @cookbooks = {}
      end

      def add_cookbook_from_directory(path_to_cookbook)
        path_to_cookbook  = Utils::FileHelper.cookbook_path_in_directory(path_to_cookbook)
        cookbook          = Ridley::Chef::Cookbook.from_path(path_to_cookbook)

        add_to_cookbook_store(cookbook.metadata)
        new_directory = File.join(directory, "/#{cookbook.name}")
        Utils::FileHelper.remove_directory(new_directory)
        Utils::FileHelper.copy_directory(path_to_cookbook, new_directory)
      end

      def installed?(cookbook_name, cookbook_version)
        !!(cookbooks[cookbook_name] &&
          cookbooks[cookbook_name].include?(cookbook_version))
      end

      private

      def add_to_cookbook_store(cookbook_metadata)
        @cookbooks[cookbook_metadata.name] ||= []
        @cookbooks[cookbook_metadata.name] << cookbook_metadata.version
      end

    end
  end
end
