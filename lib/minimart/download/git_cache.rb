module Minimart
  module Download
    # GitCache manages cloning repositories, and storing them for later access.
    class GitCache

      class << self
        # Get the GitCache singleton instance
        # @return [Minimart::Download::GitCache]
        def instance
          @instance ||= GitCache.new
        end
      end

      def initialize
        self.cache = {}
      end

      # Get a repository from the GitCache. This repository will be cloned, if
      # it hasn't been already.
      # @param [String] repo_location Any location that can be cloned by Git (Path, URL).
      # @return [Git::Base]
      def get_repository(repo_location)
        cache[repo_location] ||= clone_bare_repo(repo_location)
      end

      # Get the local path to the repository passed in. This repository will be cloned,
      # if it hasn't been already.
      # @param [String] repo_location Any location that can be cloned by Git (Path, URL).
      # @return [String] The path to the repository
      def local_path_for(repo_location)
        get_repository(repo_location).repo.path
      end

      # This method will empty the GitCache.
      def clear
        cache.values.each do |git|
          FileUtils.remove_entry(git.repo.path)
        end
        self.cache = {}
      end

      # See if the GitCache has any reference to a repository location.
      # @param [String] repo_location Any location that can be cloned by Git (Path, URL).
      # @return [Boolean]
      def has_location?(repo_location)
        cache.has_key? repo_location
      end

      private

      attr_accessor :cache

      def clone_bare_repo(repo_location)
        Configuration.output.puts "-- Cloning Git Repository From '#{repo_location}'"
        Git.clone(repo_location, Dir.mktmpdir, bare: true)
      end

    end
  end
end
