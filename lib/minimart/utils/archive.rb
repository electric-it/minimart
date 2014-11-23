require 'archive/tar/minitar'
require 'zlib'

module Minimart
  module Utils
    class Archive

      def self.extract_archive(archive_file, destination)
        ::Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(archive_file, 'rb')), destination)
      end

      def self.extract_cookbook(archive_file, destination)
        tmpdir = Dir.mktmpdir
        extract_archive(archive_file, tmpdir)

        FileUtils.rmdir destination

        if Minimart::Utils::FileHelper.cookbook_file_in_path?(tmpdir)
          FileUtils.mv tmpdir, destination, force: true
        else
          cookbook_dir = Minimart::Utils::FileHelper.find_cookbook_directory(tmpdir)
          FileUtils.mv cookbook_dir, destination, force: true
        end
      end

    end
  end
end
