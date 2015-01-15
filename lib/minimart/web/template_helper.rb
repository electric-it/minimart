require 'erb'
require 'tilt/erb'

module Minimart
  module Web
    module TemplateHelper

      def render_template(template_name, context = self, locals = {})
        template(template_name).render(context, locals)
      end

      def render_in_base_layout(&block)
        template('layout.erb').render self, {}, &block
      end

      def template(template_name)
        Tilt::ERBTemplate.new(template_file(template_name))
      end

      def template_file(templ)
        File.join(minimart_web_directory, 'templates', templ)
      end

      def minimart_web_directory
        File.join(File.dirname(__FILE__), '..', '..', '..', 'web')
      end

      def asset_path(resource)
        path_to_assets = base_path_to('assets')
        Utils::Http.concat_url_fragment(path_to_assets, resource)
      end

      def base_path_to(resource = '')
        result = resource
        level.times { result = "../#{result}" }
        result
      end

      def cookbook_download_path(cookbook)
        base_path_to "cookbook_files/#{cookbook.name}/#{cookbook.web_friendly_version}/#{cookbook}.tar.gz"
      end

      def cookbook_path(cookbook)
        "#{cookbook_dir(cookbook)}/#{cookbook.version}.html"
      end

      def cookbook_dir(cookbook)
        "/cookbooks/#{cookbook.name}"
      end

      def level
        0
      end

    end
  end
end
