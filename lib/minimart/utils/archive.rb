require 'archive/tar/minitar'
require 'zlib'

module Minimart
  module Utils
    module Archive

      def self.extract_archive(archive_file, destination)
        tar = Zlib::GzipReader.new(File.open(archive_file, 'rb'))
        ::Archive::Tar::Minitar.unpack(tar, destination)
      end

    end
  end
end
