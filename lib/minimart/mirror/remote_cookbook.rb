module Minimart
  module Mirror
    class RemoteCookbook

      attr_reader :name,
                  :version,
                  :dependencies,
                  :location_path,
                  :download_url

      def initialize(options)
        @name          = options[:name] || options['name']
        @version       = options[:version] || options['version']
        @location_path = options[:location_path] || options['location_path']
        @download_url  = options[:download_url] || options['download_url']
        @dependencies  = options[:dependencies] || options['dependencies'] || {}
      end

    end
  end
end
