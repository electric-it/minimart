module Minimart
  module Download
    class GitCache

      def initialize
        @cache = {}
      end

      def get_repository(repo_location)
        @cache[repo_location] ||= clone_bare_repo(repo_location)
      end

      private

      def clone_bare_repo(repo_location)
        Configuration.output.puts "-- Cloning Git Repository From '#{repo_location}'"
        Git.clone(repo_location, Dir.mktmpdir, bare: true)
      end

    end
  end
end
