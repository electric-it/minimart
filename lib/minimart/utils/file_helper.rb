module Minimart
  module Utils
    class FileHelper
      def self.cookbook_path_in_directory(path)
        cookbook_file_in_path?(path) ? path : find_cookbook_directory(path)
      end

      def self.find_cookbook_directory(path)
        Dir.glob(::File.join(path, '/*/')).select { |d| cookbook_file_in_path?(d) }.first
      end

      def self.cookbook_file_in_path?(path)
        ::File.exists?(File.join(path, 'metadata.json')) ||
          ::File.exists?(File.join(path, 'metadata.rb'))
      end

      def self.make_temporary_directory
        Dir.mktmpdir
      end

      def self.remove_directory(path)
        return unless Dir.exists?(path)
        FileUtils.remove_dir(path)
      end

      def self.move_directory(source, destination)
        FileUtils.mv source, destination
      end

    end
  end
end
