require 'git'

module Minimart
  module Download
    class GitRepository

      attr_reader :url

      def initialize(url)
        @url = url
      end

      def download(commitish)
        bare_repo_path = Dir.mktmpdir
        bare_repo      = Git.clone(url, bare_repo_path, bare: true)
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
