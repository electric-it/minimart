module Minimart
  class Mirror
    module CookbookDownloader

      def self.download(cookbook, destination)
        ##
        # TODO support all Berkshelf API sources
        ##
        archive_file = Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", cookbook.download_url)
        Utils::Archive.extract_cookbook(archive_file, destination)
      end

    end
  end
end
