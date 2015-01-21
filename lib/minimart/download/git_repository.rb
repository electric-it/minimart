require 'git'
require 'minimart/download/git_cache'

module Minimart
  module Download
    # GitRepository manages cloning, and checking out a given Git endpoint.
    class GitRepository

      # @return [String] any location that can be cloned by Git (Path, URL).
      attr_reader :location

      # @param [String] location Any location that can be cloned by Git (Path, URL).
      def initialize(location)
        @location = location
      end

      # Fetch the given commit, branch, or tag.
      # @param commitish The commit, branch, or tag to clone for the given location.
      # @yield [Dir] Tmp directory containing the repository. This directory will be removed when the block exits.
      def fetch(commitish, &block)
        Dir.mktmpdir do |path|
          result_repo = Git.clone(bare_repo_path, path)
          result_repo.fetch(bare_repo_path, tags: true)
          result_repo.reset_hard(bare_repo.revparse(commitish))
          block.call(path)
        end
      end

      private

      def bare_repo_path
        bare_repo.repo.path
      end

      def bare_repo
        @bare_repo ||= Download::GitCache.instance.get_repository(location)
      end

    end
  end
end
