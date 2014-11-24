module Minimart
  class Mirror
    class Source

      attr_accessor :url,
                    :dependencies,
                    :universe

      alias_method :explicit_dependencies, :dependencies

      def initialize(url, raw_cookbooks)
        self.url          = url
        self.dependencies = build_dependencies(raw_cookbooks)
        self.universe     = Universe.new(url)
      end

      def download_explicit_dependencies(&block)
        explicit_dependencies.each do |dependency|
          download_cookbook dependency, &block
        end
      end

      def download_cookbook(dependency, &block)
        cookbook       = universe.find_cookbook_for_requirements(dependency.name, dependency.requirements)
        archive_file   = download_cookbook_archive_file(cookbook)
        block.call(cookbook, archive_file)
      end

      def resolve_dependency(name, requirements)
        universe.resolve_dependency(name, requirements)
      end

      private

      def build_dependencies(raw_cookbooks)
        raw_cookbooks.each_with_object([]) do |cookbook, memo|
          cookbook_name     = cookbook[0]
          cookbook_versions = cookbook[1]['versions']

          dependencies = cookbook_versions.map do |version|
            Hashie::Mash.new(name: cookbook_name, requirements: version)
          end

          memo.concat dependencies
        end
      end

      def download_cookbook_archive_file(cookbook)
        Configuration.output.puts "Downloading #{cookbook.name} #{cookbook.version}"

        Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", cookbook.download_url)
      end

    end
  end
end
