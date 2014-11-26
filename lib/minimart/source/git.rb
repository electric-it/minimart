module Minimart
  class Source
    class Git

      attr_accessor :url,
                    :branches,
                    :tags,
                    :refs,
                    :git_repo

      def initialize(url, opts)
        self.url      = url
        self.branches = opts[:branches] || []
        self.tags     = opts[:tags] || []
        self.refs     = opts[:refs] || []
      end

      def download_cookbooks(output_directory, &block)
        Configuration.output.puts "Downloading cookbooks from Git Repo: (#{url})"
        fetch_git_repo

        versions_to_download.each do |version|
          git_repo.checkout version
          git_repo.reset_hard version
          new_directory = File.join(output_directory, "/#{cookbook_name}-#{version}")
          Utils::FileHelper.copy_directory(tmp_path, new_directory)
          Utils::FileHelper.remove_directory(File.join(new_directory, '/.git'))

          metadata = cookbook_metadata
          mash = Hashie::Mash.new(name: metadata.name, version: metadata.version, dependencies: metadata.dependencies)
          block.call(mash)
        end
      end

      def resolve_dependency(name, requirements)
        return nil
      end

      private

      def fetch_git_repo
        self.git_repo ||= Git.clone(url, tmp_path)
      end

      def versions_to_download
        branches | tags | refs
      end

      def cookbook_name
        @cookbook_name ||= cookbook_metadata.name
      end

      def cookbook_metadata
        Ridley::Chef::Cookbook.from_path(tmp_path).metadata
      end

      def tmp_path
        @tmp_path ||= Utils::FileHelper.make_temporary_directory
      end

    end
  end
end
