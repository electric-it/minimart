require 'minimart/web/universe_generator'
require 'minimart/web/html_generator'

module Minimart
  module Commands
    # Web is the main entrance point for building the web interface for Minimart.
    # This class will generate the index file to be used by Berkshelf, archived
    # cookbooks, and HTML used to browse the available inventory.
    class Web

      # @return [String] The directory that the inventory is stored in.
      attr_reader :inventory_directory

      # @return [String] The directory to store the web output.
      attr_reader :web_directory

      # @return [String] The web endpoint where Minimart will be hosted.
      attr_reader :web_endpoint

      # @return [Boolean] Determine whether or not to generate HTML output
      attr_reader :can_generate_html


      # @param [Hash] opts
      # @option opts [String] :inventory_directory The directory that the inventory is stored in.
      # @option opts [String] :web_directory The directory to store the web output.
      # @option opts [String] :host The web endpoint where Minimart will be hosted.
      # @option opts [Boolean] :can_generate_html Determine whether or not to generate HTML output
      def initialize(opts = {})
        @inventory_directory = File.expand_path(opts[:inventory_directory])
        @web_directory       = File.expand_path(opts[:web_directory])
        @web_endpoint        = opts[:host]
        @can_generate_html   = opts.fetch(:html, true)
      end

      # Generate the web output.
      def execute!
        make_web_directory
        generate_universe
        generate_html
        print_success_message
      end

      private

      attr_reader :cookbooks

      def make_web_directory
        FileUtils.mkdir_p web_directory
      end

      def generate_universe
        Configuration.output.puts "Building the cookbook index."

        generator = Minimart::Web::UniverseGenerator.new(
          web_directory: web_directory,
          endpoint:      web_endpoint,
          cookbooks:     cookbooks)

        generator.generate
      end

      def generate_html
        return unless generate_html?

        Configuration.output.puts "Generating Minimart HTML."

        generator = Minimart::Web::HtmlGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks)

        generator.generate
      end

      def cookbooks
        @cookbooks ||= Minimart::Web::Cookbooks.new(inventory_directory: inventory_directory)
      end

      def generate_html?
        can_generate_html
      end

      def print_success_message
        Configuration.output.puts_green('Minimart successfully built the static web files!')
        Configuration.output.puts_green("The static web files can be found in #{relative_web_path}")
      end

      def relative_web_path
        File.join('.', Pathname.new(web_directory).relative_path_from(Pathname.pwd))
      end

    end
  end
end
