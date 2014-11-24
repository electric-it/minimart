require 'archive/tar/minitar'
require 'zlib'

module Minimart
  module Utils
    module Archive

      def self.extract_archive(archive_file, destination)
        tar = Zlib::GzipReader.new(File.open(archive_file, 'rb'))
        ::Archive::Tar::Minitar.unpack(tar, destination)
      end

      def self.extract_cookbook(archive_file, destination)
        tmpdir = FileHelper.make_temporary_directory
        extract_archive(archive_file, tmpdir)
        FileHelper.remove_directory(destination)
        FileHelper.move_directory FileHelper.cookbook_path_in_directory(tmpdir), destination
      end

    end
  end
end
