module Minimart
  module Utils
    module FileHelper

      def self.cookbook_path_in_directory(path)
        cookbook_in_path?(path) ? path : find_cookbooks_in_directory(path).first
      end

      def self.find_cookbooks_in_directory(path)
        Dir.glob(File.join(path, '/*/')).select { |d| cookbook_in_path?(d) }
      end

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
