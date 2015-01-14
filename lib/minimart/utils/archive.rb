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

        Dir.chdir(File.join(parent_directory, source_directory)) do |directory|
          tgz = Zlib::GzipWriter.new(File.open(destination, 'wb'))
          ::Archive::Tar::Minitar.pack(directory, tgz)
        end
      end

    end
  end
end
