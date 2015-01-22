require 'minimart/download/cookbook'

module Minimart
  module Mirror

    # A wrapper around a cookbook as found in the universe.json file from an
    # external source (Chef Supermarket, etc...).
    class RemoteCookbook

      # @return [String] the name of the cookbook
      attr_accessor :name

      # @return [String] the version of the cookbook
      attr_accessor :version

      # @return [Hash<String,String>] any dependencies the cookbook has
      attr_accessor :dependencies

      # @return [String] the path to the cookbook
      attr_accessor :location_path

      # @return [String] the type of location the cookbook is stored in (supermarket, etc.)
      attr_accessor :location_type

      # @return [String] URL to download the cookbook
      attr_accessor :download_url

      # @param [Hash] opts
      # @option opts [String] name The name of the cookbook
      # @option opts [String] version The version of the cookbook
      # @option opts [String] location_path The path to the cookbook
      # @option opts [String] download_url URL to download the cookbook
      # @option opts [Hash] dependencies A hash containing any of the cookbook's dependencies.
      # @option opts [String] location_type The type of location the cookbook is stored in (supermarket, etc.)
      def initialize(opts)
        @name          = fetch_from_options(opts, 'name')
        @version       = fetch_from_options(opts, 'version')
        @location_path = fetch_from_options(opts, 'location_path')
        @download_url  = fetch_from_options(opts, 'download_url')
        @dependencies  = fetch_from_options(opts, 'dependencies') || {}
        @location_type = fetch_from_options(opts, 'location_type')
      end

      # Download this remote cookbook
      # @yield [Dir] The path to the downloaded cookbook. This directory will be removed when the block exits.
      def fetch(&block)
        Download::Cookbook.new(self).fetch(&block)
      end

      # Convert this remote cookbook to a Hash
      # @return [Hash]
      def to_hash
        {
          source_type: location_type,
          location:    location_path
        }
      end

      # Get the location_path as a URI
      # @return [URI]
      def location_path_uri
        URI.parse(location_path)
      end

      def web_friendly_version
        version.gsub('.', '_')
      end

      private

      def fetch_from_options(opts, key)
        opts[key] || opts[key.to_sym]
      end

    end
  end
end
