module Minimart
  module InventoryCookbook
    class GitCookbook < BaseCookbook

      attr_reader :name,
                  :url,
                  :branch,
                  :ref,
                  :tag

      def initialize(name, opts)
        super

        @branch = opts[:branch]
        @ref    = opts[:ref]
        @tag    = opts[:tag]
        @url    = opts[:url]
      end

      def location_specification?
        true
      end

      def install(output_directory)
        git_repo.checkout version
        git_repo.reset_hard version
        new_directory = File.join(output_directory, "/#{name}-#{version}")
        Utils::FileHelper.copy_directory(tmp_path, new_directory)
        Utils::FileHelper.remove_directory(File.join(new_directory, '/.git'))

        metadata = Ridley::Chef::Cookbook.from_path(new_directory).metadata

        @cookbook = Minimart::Mirror::RemoteCookbook.new(
          name:         metadata.name,
          version:      metadata.version,
          dependencies: metadata.dependencies)

        @version_requirement = @cookbook.version

        return @cookbook
      end

      private

      def version
        ref || branch || tag
      end

      def git_repo
        @git_repo ||= Git.clone(url, tmp_path)
      end

      def tmp_path
        @tmp_path ||= Utils::FileHelper.make_temporary_directory
      end

    end
  end
end
