module Minimart
  module Download
    class GitCache

      class << self
        def instance
          @instance ||= GitCache.new
        end
      end

      def initialize
        self.cache = {}
      end

      def get_repository(repo_location)
        cache[repo_location] ||= clone_bare_repo(repo_location)
      end

      def clear
        cache.values.each do |git|
          FileUtils.remove_entry(git.repo.path)
        end
        self.cache = {}
      end

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
