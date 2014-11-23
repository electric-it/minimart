module Minimart
  module Utils
    class FileHelper
      def self.find_cookbook_directory(path)
        Dir.glob(::File.join(path, '/*/')).select { |d| cookbook_file_in_path?(d) }.first
      end

      def self.cookbook_file_in_path?(path)
        ::File.exists?(File.join(path, 'metadata.json')) ||
          ::File.exists?(File.join(path, 'metadata.rb'))
      end
    end
  end
end
