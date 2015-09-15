module Minimart
  module Utils
    # FileHelper contains helper methods for dealing with the file system.
    class NoCookbooksFoundError < StandardError; end
    module FileHelper

      # Find the first cookbook in the given path
      # @param [String] path The directory to search for cookbooks in
      # @return [String] The path to the cookbook
      def self.cookbook_path_in_directory(path)
        cookbook_in_path?(path) ? path : find_cookbooks_in_directory(path).first
      end

      # List all of the cookbooks in a given directory
      # @param [String] path The directory to find cookbooks in
      # @return [Array<String>] An array of paths to any cookbooks found in the supplied path.
      #raise NoCookbooksFoundError if cookbooks.empty?
      def self.find_cookbooks_in_directory(path)
        Dir.glob(File.join(path, '/*/')).select { |d| cookbook_in_path?(d) }
      end

      # Determine whether or not a given directory contains a cookbook.
      # @param [String] path The directory to check
      # @return [Boolean]
      def self.cookbook_in_path?(path)
        file_exists?(File.join(path, 'metadata.json')) ||
          file_exists?(File.join(path, 'metadata.rb'))
      end

      def self.file_exists?(path)
        File.exists?(path)
      end

    end
  end
end
