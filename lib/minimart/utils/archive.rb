require 'archive/tar/minitar'
require 'zlib'
require 'minimart/mirror/download_metadata'

module Minimart
  module Utils

    # Archive manages tarring, and gzipping files
    module Archive

      # Extract a tar.gz archive
      # @param [String] archive_file The path to the archive file
      # @param [String] destination The directory to unpack the archive to
      def self.extract_archive(archive_file, destination)
        tar = Zlib::GzipReader.new(File.open(archive_file, 'rb'))
        ::Archive::Tar::Minitar.unpack(tar, destination)
      end

      # Build a tar.tz archive from a directory
      # @param [String] parent_directory The directory containing the directory to archive
      # @param [String] source_directory The name of the directory to archive
      # @param [String] destination The path to store the tar.gz archive
      def self.pack_archive(parent_directory, source_directory, destination)
        Dir.chdir(parent_directory) do |directory|
          tgz = Zlib::GzipWriter.new(File.open(destination, 'wb'))
          ::Archive::Tar::Minitar.pack(source_directory, tgz)
        end
      end

    end
  end
end
