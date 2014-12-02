module Minimart
  module Utils
    module FileHelper

      def self.cookbook_path_in_directory(path)
        cookbook_file_in_path?(path) ? path : find_cookbook_directory(path)
      end

      def self.find_cookbook_directory(path)
        Dir.glob(File.join(path, '/*/')).select { |d| cookbook_file_in_path?(d) }.first
      end

      def self.cookbook_file_in_path?(path)
        file_exists?(File.join(path, 'metadata.json')) ||
          file_exists?(File.join(path, 'metadata.rb'))
      end

      def self.file_exists?(path)
        File.exists?(path)
      end

    end
  end
end
