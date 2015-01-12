require 'git'
require 'minimart/download/git_cache'

module Minimart
  module Download
    class GitRepository

      class << self
        def cache
          @cache ||= GitCache.new
        end
      end

      attr_reader :location

      def initialize(location)
        @location = location
      end

      def fetch(commitish)
        result      = Dir.mktmpdir
        result_repo = Git.clone(bare_repo_path, result)
        result_repo.fetch(bare_repo_path, tags: true)
        result_repo.reset_hard(bare_repo.revparse(commitish))
        result
      end

      private

      def bare_repo_path
        bare_repo.repo.path
      end

      def bare_repo
        @bare_repo ||= self.class.cache.get_repository(location)
      end

    end
  end
end
