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
      # @param [Minimart::Cookbook] cookbook The cookbook to archive
      # @param [String] destination The path to store the tar.gz archive
      def self.pack_archive(cookbook, destination)
        Dir.mktmpdir do |tmp|
          Dir.chdir(tmp) do
            archive_dir = File.join(tmp, cookbook.name)
            FileUtils.mkdir_p(archive_dir)
            FileUtils.cp_r(File.join(cookbook.path, '.'), archive_dir)
            meta_file = File.join(archive_dir, Minimart::Mirror::DownloadMetadata::FILE_NAME)
            FileUtils.remove_entry(meta_file) if File.exists?(meta_file)

            tgz = Zlib::GzipWriter.new(File.open(destination, 'wb'))
            ::Archive::Tar::Minitar.pack(cookbook.name, tgz)
          end
        end
      end

    end
  end
end
