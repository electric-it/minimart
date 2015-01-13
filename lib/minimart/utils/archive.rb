require 'archive/tar/minitar'
require 'zlib'

module Minimart
  module Utils
    module Archive

      def self.extract_archive(archive_file, destination)
        tar = Zlib::GzipReader.new(File.open(archive_file, 'rb'))
        ::Archive::Tar::Minitar.unpack(tar, destination)
      end

      def self.pack_archive(parent_directory, source_directory, destination)
        Dir.chdir(parent_directory)
        tar_name = File.join(source_directory, '.tar')
        ::Archive::Tar::Minitar.pack(source_directory, tar_name, true)

        tar_contents = File.open(tar_name).read
        Zlib::GzipWriter.open(destination) do |gz|
          gz.write tar_contents
        end
      end

    end
  end
end
