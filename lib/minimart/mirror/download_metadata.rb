module Minimart
  module Mirror
    # This class can be used to parse, and create `.minimart.json` files to
    # store information about when, and how Minimart downloaded a given cookbook.
    class DownloadMetadata

      FILE_NAME = '.minimart.json'

      # @return [String] the path to the directory containing the cookbook.
      attr_reader :path_to_cookbook

      # @return [Hash] the contents of the metadata file.
      attr_reader :metadata

      # @param [String] path_to_cookbook The path to the directory containing the cookbook.
      def initialize(path_to_cookbook)
        @path_to_cookbook = path_to_cookbook
        parse_file
      end

      # Write the given contents to the metadata file. This will overwrite any
      # existing contents.
      # @param [Hash] contents The hash of data to write to the file.
      def write(contents = {})
        File.open(file_path, 'w+') do |file|
          @metadata = contents
          @metadata.merge!('downloaded_at' => Time.now.utc.iso8601)

          file.write(metadata.to_json)
        end
      end

      # @return [Time] The downloaded_at time found in the metadata file.
      def downloaded_at
        return unless self['downloaded_at']
        Time.iso8601(metadata['downloaded_at']).utc
      end

      def [](key)
        metadata[key] if metadata
      end

      def has_key?(key)
        (metadata ? metadata.has_key?(key) : false)
      end

      private

      def parse_file
        return unless File.exists?(file_path)
        file_contents = File.open(file_path).read
        @metadata = JSON.parse(file_contents)
      end

      def file_path
        File.join(path_to_cookbook, FILE_NAME)
      end

    end
  end
end
