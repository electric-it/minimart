module Minimart
  module Web
    class CookbookShowPageGenerator
      include TemplateHelper

      attr_reader :web_directory
      attr_reader :cookbooks

      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      def generate
        clean_web_cookbooks_directory
        make_web_cookbooks_directory
        create_html_files
      end

      private

      def clean_web_cookbooks_directory
        return unless Dir.exists?(cookbooks_directory)
        FileUtils.remove_entry(cookbooks_directory)
      end

      def make_web_cookbooks_directory
        FileUtils.mkdir_p(cookbooks_directory)
      end

      def create_html_files
        cookbooks.each do |cookbook_name, versions|
          versions.each do |cookbook|
            write_to_file(file(cookbook), template_content(cookbook, versions))
          end
        end
      end

      def file(cookbook)
        FileUtils.mkdir_p(File.join(web_directory, cookbook_dir(cookbook)))
        File.join(web_directory, cookbook_file(cookbook))
      end

      def template_content(cookbook, versions)
        render_in_base_layout do
          render_template('cookbook_show.erb', self, {cookbook: cookbook, other_versions: versions})
        end
      end

      def write_to_file(file_path, content)
        File.open(file_path, 'w+') { |f| f.write(content) }
      end

      def cookbooks_directory
        File.join(web_directory, 'cookbooks')
      end

      def cookbook_for_requirement(name, version_requirement)
        (cookbooks[name] || []).find do |c|
          c.satisfies_requirement?(version_requirement)
        end
      end

      def level
        2
      end

    end
  end
end
