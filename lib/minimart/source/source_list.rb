module Minimart
  class Source
    class SourceList

      class << self
        def build_source(url, opts)
          if opts[:type] == 'git'
            Source::Git.new(url, opts)
          else
            Source::Supermarket.new(url, opts[:cookbooks])
          end
        end
      end

      attr_reader :sources

      def initialize
        @sources = []
      end

      def build_source(url, opts)
        add(self.class.build_source(url, opts))
      end

      def add(source)
        sources << source
      end

      def each(&block)
        sources.each &block
      end

      def map(&block)
        sources.map &block
      end

      # git || local file path
      def with_location_specifications
        sources.select { |s| !s.is_a?(Source::Supermarket) }
      end

      def with_supermarket_specifications
        sources.select { |s| s.is_a?(Source::Supermarket) }
      end

    end
  end
end
