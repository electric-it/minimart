require 'erb'
require 'tilt/erb'

module Minimart
  module Web
    # Various methods to help with template rendering
    module TemplateHelper

      # Render a template
      # @param [String] template_name The name of the template to render
      # @param [Binding] context The context to use while rendering the template
      # @param [Hash] locals Any local variables to use while rendering the template
      # @return [String] The rendered template content
      def render_template(template_name, context = self, locals = {})
        template(template_name).render(context, locals)
      end

      # Render a template within the base layout (layout.erb)
      # @yield
      def render_in_base_layout(&block)
        template('layout.erb').render self, {}, &block
      end

      # Build a template from the provided template name
      # @param [String] template_name The name of the template to build
      # @return [Tilt::ERBTemplate]
      def template(template_name)
        Tilt::ERBTemplate.new(template_file(template_name))
      end

      # The path to a given template file
      # @param [String] template_name The template to build a path for
      # @return [String] The path to the template file
      def template_file(template_name)
        File.join(minimart_web_directory, 'templates', template_name)
      end

      # @return [String] The path to the Minimart web directory
      def minimart_web_directory
        File.join(Minimart.root_path, '..', 'web')
      end

      # Get the path for a web asset (CSS, JS, etc...)
      # @param [String] resource The asset to get a path for.
      # @return [String] The path to the asset within the Minimart web directory
      def asset_path(resource)
        path_to_assets = base_path_to('assets')
        Utils::Http.concat_url_fragment(path_to_assets, resource)
      end

      # Build a relative path to the given resource
      # @param [String] resource The resource to build a path for.
      # @return [String] The relative path
      def base_path_to(resource = '')
        result = resource
        level.times { result = "../#{result}" }
        result
      end

      # The relative path to download an archived cookbook file.
      # @param [Minimart::Cookbook] The cookbook to get a download path for
      # @return [String] The path to the archive file
      def cookbook_download_path(cookbook)
        base_path_to "cookbook_files/#{cookbook.name}/#{cookbook.web_friendly_version}/#{cookbook}.tar.gz"
      end

      # The relative path to a cookbook show page
      # @param [Minimart::Cookbook] The cookbook to get a path for
      # @return [String] The path to the show page
      def cookbook_path(cookbook)
        base_path_to(cookbook_file(cookbook))
      end

      # The path to a cookbook show page from the root of the web directory
      # @param [Minimart::Cookbook] The cookbook to get a path for
      # @return [String] The path to the cookbook show page
      def cookbook_file(cookbook)
        "#{cookbook_dir(cookbook)}/#{cookbook.version}.html"
      end

      # The path to a cookbook's HTML files
      # @param [Minimart::Cookbook] The cookbook to get a path for
      # @return [String] The path to the cookbook directory
      def cookbook_dir(cookbook)
        "cookbooks/#{cookbook.name}"
      end

      # @return [String] The relative path to the index.html file
      def home_path
        base_path_to 'index.html'
      end

      # @return [Integer] The number of directories nested under the web directory.
      #   This is used for building relative paths.
      def level
        0
      end

      # @return [String] The relative path to the cookbook search route
      def search_path
        "#{home_path}#search/"
      end

      # Get an icon name for a given platform (amazon, centos, etc...)
      # @param [String] The platform to get an icon for
      # @return [String] The icon name
      def platform_icon(platform)
        case platform.downcase
        when /amazon/i     then 'aws'
        when /centos/i     then 'centos'
        when /debian/i     then 'debian'
        when /fedora/i     then 'fedora'
        when /freebsd/i    then 'freebsd'
        when /linuxmint/i  then 'linux-mint'
        when /mac_os_x/i   then 'apple'
        when /oracle/i     then 'oracle'
        when /raspbian/i   then 'raspberrypi'
        when /redhat/i     then 'redhat'
        when /solaris/i    then 'solaris'
        when /suse/i       then 'suse'
        when /ubuntu/i     then 'ubuntu'
        when /windows/i    then 'windows'
        else
          'laptop'
        end
      end

    end
  end
end
