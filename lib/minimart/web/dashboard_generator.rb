module Minimart
  module Web
    # Generate the main Minimart HTML dashboard (index.html)
    class DashboardGenerator
      include Minimart::Web::TemplateHelper

      # @return [String] the directory to put any generated HTML in
      attr_reader :web_directory

      # @return [Minimart::Web::Cookbooks] the cookbooks to generate HTML for.
      attr_reader :cookbooks

      # @return [String] The generated HTML content
      attr_reader :template_content

      # @param [Hash] opts
      # @option opts [String] :web_directory The directory to put any generated HTML in
      # @option opts [String] :cookbooks The cookbooks to generate HTML for
      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      # Generate the dashboard!
      def generate
        generate_template_content
        write_template_to_index_file
      end

      private

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
