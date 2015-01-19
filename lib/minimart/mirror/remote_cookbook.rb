module Minimart
  module Mirror
    class RemoteCookbook

      attr_reader :name,
                  :version,
                  :dependencies,
                  :location_path,
                  :location_type,
                  :download_url

      def initialize(options)
        @name          = fetch_from_options(options, 'name')
        @version       = fetch_from_options(options, 'version')
        @location_path = fetch_from_options(options, 'location_path')
        @download_url  = fetch_from_options(options, 'download_url')
        @dependencies  = fetch_from_options(options, 'dependencies') || {}
        @location_type = fetch_from_options(options, 'location_type')
      end

      def fetch(&block)
        Download::Supermarket.download(self) do |path_to_cookbook|
          block.call(path_to_cookbook)
        end
      end

      def to_hash
        {
          source_type: location_type,
          location:    URI.parse(location_path).host
        }
      end

      private

      def fetch_from_options(opts, key)
        opts[key] || opts[key.to_sym]
      end

    end
  end
end
