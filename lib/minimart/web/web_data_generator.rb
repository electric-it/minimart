require 'minimart/web/template_helper'

module Minimart
  class Web
    # Given a collection of cookbooks, this class will generate the necessary
    # JSON output to power the main dashboard.
    class WebDataGenerator
      include TemplateHelper

      FILE_NAME = 'data.json'

      attr_reader :web_directory
      attr_reader :cookbooks

      def initialize(opts)
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      def generate
        build_json
        write_data_file

        return file_path
      end

      private

      attr_reader :json

      def build_json
        @json = cookbooks.inject([]) do |memo, cookbook|
          memo << {
            name:           cookbook.name,
            recent_version: cookbook.version,
            description:    cookbook.description,
            maintainer:     cookbook.maintainer,
            download_url:   cookbook_download_path(cookbook),
            url:            cookbook_path(cookbook)
          }
        end
      end

      def write_data_file
        File.open(file_path, 'w+') { |f| f.write(json.to_json) }
      end

      def file_path
        @file_path ||= File.join(web_directory, FILE_NAME)
      end

    end
  end
end
