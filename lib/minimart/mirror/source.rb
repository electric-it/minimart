module Minimart
  class Mirror
    class Source

      attr_accessor :url,
                    :cookbooks,
                    :universe

      alias_method :explicit_dependencies, :cookbooks

      def initialize(url, raw_cookbooks)
        self.url       = url
        self.cookbooks = build_cookbooks(raw_cookbooks)
        self.universe  = Universe.new(url)
      end

      def download_explicit_dependencies(&block)
        explicit_dependencies.each do |dependency|
          download_cookbook dependency, &block
        end
      end

      def download_cookbook(dependency, &block)
        cookbook     = universe.find_cookbook(dependency.name, dependency.version)
        archive_file = download_cookbook_archive_file(cookbook)
        block.call(cookbook, archive_file)
      end

      def resolve_dependency(name, requirements)
        universe.resolve_dependency(name, requirements)
      end

      private

      def build_cookbooks(raw_cookbooks)
        raw_cookbooks.each_with_object([]) do |cookbook, memo|
          cookbook_name     = cookbook[0]
          cookbook_versions = cookbook[1]['versions']

          cookbooks = cookbook_versions.map do |version|
            Hashie::Mash.new(name: cookbook_name, version: version)
          end

          memo.concat cookbooks
        end
      end

      def download_cookbook_archive_file(cookbook)
        Configuration.output.puts "Downloading #{cookbook.name} #{cookbook.version}"

        Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", cookbook.download_url)
      end

    end
  end
end
