require 'git'

module Minimart
  module Download
    class GitRepository

      attr_reader :location

      def initialize(location)
        @location = location
      end

      def fetch(commitish)
        bare_repo_path = Dir.mktmpdir
        bare_repo      = Git.clone(location, bare_repo_path, bare: true)
        revision       = bare_repo.revparse(commitish)

        result = Dir.mktmpdir
        result_repo = Git.clone(bare_repo_path, result)
        result_repo.fetch(bare_repo_path, tags: true)
        result_repo.reset_hard(revision)
        result
      end

    end
  end
end
