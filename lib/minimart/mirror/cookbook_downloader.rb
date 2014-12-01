module Minimart
  class Mirror
    module CookbookDownloader

      def self.download(cookbook, destination)
        ##
        # TODO support all Berkshelf API sources
        ##
        Configuration.output.puts "-- Downloading #{cookbook.name} #{cookbook.version}"

        directory = "#{cookbook.name}-#{cookbook.version}"
        archive_file = Utils::Http.get_binary(directory, cookbook.download_url)
        Utils::Archive.extract_cookbook(archive_file, File.join(destination, directory))
      end

    end
  end
end
