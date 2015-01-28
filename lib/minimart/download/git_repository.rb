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
        Dir.mktmpdir do |tmpdir|
          result_repo = Git.clone(bare_repo_path, tmpdir)
          result_repo.fetch(bare_repo_path, tags: true)
          result_repo.reset_hard(bare_repo.revparse(commitish))
          block.call(tmpdir) if block
        end
      end

      private

      def bare_repo_path
        @bare_repo_path ||= Download::GitCache.instance.local_path_for(location)
      end

      def bare_repo
        @bare_repo ||= Download::GitCache.instance.get_repository(location)
      end

    end
  end
end
