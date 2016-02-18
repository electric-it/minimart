require 'minimart/mirror/download_metadata'
require 'minimart/utils/file_helper'

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
        @metadata = {}

        load_local_inventory

      end

      # :nodoc:
      def add_cookbook_to_store(name, version)
        cookbooks[name] ||= []
        cookbooks[name] << version

        metadata[name] ||= {}
        metadata[name][version] = local_path_for("#{name}-#{version}")
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

      def cookbook_for_requirement(requirement)
        #we dont handle caching for anything other than git requirements in this function.
        return nil unless requirement.is_a?(InventoryRequirement::GitRequirement)
        # if this is a branch, we can't assume that the commit is the same (remote could have changed)
        return nil if requirement.branch

        @metadata.each{ |cookbook, versions|

          versions.each{ |version, lazy_metadata|
            #lazy populate the metadata
            if(lazy_metadata.is_a?(String))
              lazy_metadata = Minimart::Mirror::DownloadMetadata.new(lazy_metadata)
            end

            if requirement.matching_source?(lazy_metadata)
              return "#{cookbook}-#{version}"
            end
          }
        }
        return nil
      end

      # Validate that a new resolved requirement is not in the local store
      # with different requirements. If we download two different branches
      # of the same cookbook and they both resolve to the same version, then we
      # raise an exception.
      # @param [Minimart::Cookbook] new_cookbook
      # @param [Minimart::InventoryRequirement::BaseRequirement] requirement
      # @raise [Minimart::Error::BrokenDependency]
      def validate_resolved_requirement(new_cookbook, requirement)
        return unless installed?(new_cookbook.name, new_cookbook.version)

        existing_cookbook = load_cookbook(new_cookbook)
        unless requirement.matching_source?(existing_cookbook.download_metadata)
          raise Minimart::Error::BrokenDependency, "A version of #{new_cookbook} already exists in the inventory from a different source."
        end
      end

      private

      attr_reader :cookbooks
      attr_reader :metadata

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

      def load_cookbook(cookbook)
        cookbook_from_path(local_path_for(cookbook))
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
