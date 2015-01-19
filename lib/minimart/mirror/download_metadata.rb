module Minimart
  module Mirror
    # This class can be used to parse, and create `.minimart.json` files to
    # store information about when, and how Minimart downloaded a given cookbook
    class DownloadMetadata

      FILE_NAME = '.minimart.json'

      attr_reader :path_to_cookbook
      attr_reader :metadata

      def initialize(path_to_cookbook)
        @path_to_cookbook = path_to_cookbook
        parse_file
      end

      def write(contents = {})
        File.open(file_path, 'w+') do |file|
          @metadata = contents
          @metadata.merge!('downloaded_at' => Time.now.utc.iso8601)

          file.write(metadata.to_json)
        end
      end

      def downloaded_at
        return unless metadata && metadata['downloaded_at']
        Time.iso8601(metadata['downloaded_at']).utc
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
