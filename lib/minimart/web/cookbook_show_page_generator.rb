require 'minimart/web/template_helper'

module Minimart
  class Web
    class CookbookShowPageGenerator
      include TemplateHelper

      attr_reader :web_directory
      attr_reader :cookbooks

      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      def generate
        FileUtils.mkdir_p(cookbooks_directory)

        cookbooks.each do |cookbook|
          write_to_file(file(cookbook), template_content(cookbook))
        end
      end

      private

      def file(cookbook)
        FileUtils.mkdir_p(File.join(web_directory, cookbook_dir(cookbook)))
        File.join(web_directory, cookbook_path(cookbook))
      end

      def template_content(cookbook)
        render_in_base_layout do
          render_template('cookbook_show.erb', self, {cookbook: cookbook})
        end
      end

      def write_to_file(file_path, content)
        File.open(file_path, 'w+') { |f| f.write(content) }
      end

      def cookbooks_directory
        File.join(web_directory, 'cookbooks')
      end

      def level
        2
      end

    end
  end
end
