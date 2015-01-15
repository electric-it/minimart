module Minimart
  class Web
    class DashboardGenerator
      include TemplateHelper

      attr_reader :web_directory
      attr_reader :cookbooks

      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      def generate
        generate_template_content
        write_template_to_index_file
      end

      private

      attr_reader :template_content

      def generate_template_content
        @template_content = render_in_base_layout { render_template('dashboard.erb') }
      end

      def write_template_to_index_file
        File.open(index_file, 'w+') { |f| f.write(template_content) }
      end

      def index_file
        File.join(web_directory, 'index.html')
      end

    end
  end
end
