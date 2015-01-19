require 'git'
require 'minimart/download/git_cache'

module Minimart
  module Download
    class GitRepository

      attr_reader :location

      def initialize(location)
        @location = location
      end

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
