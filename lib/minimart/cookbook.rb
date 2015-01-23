require 'ridley'
require 'semverse'

require 'minimart/web/markdown_parser'
require 'minimart/web/template_helper'

module Minimart

  # An object wrapper to get information about a cookbook.
  class Cookbook
    include Web::TemplateHelper

    # Generate a new Minimart::Cookbook from a path
    # @param [String] path The path to the cookbook directory
    # @return [Minimart::Cookbook]
    def self.from_path(path)
      path = Minimart::Utils::FileHelper.cookbook_path_in_directory(path)
      new (Ridley::Chef::Cookbook.from_path(path))
    end

    # @param [Ridley::Chef::Cookbok] raw_cookbook
    def initialize(raw_cookbook)
      @raw_cookbook = raw_cookbook
    end

    # Get the name of the cookbook
    # @return [String]
    def name
      raw_cookbook.cookbook_name
    end

    # Get the version of the cookbook
    # @return [String]
    def version
      raw_cookbook.version
    end

    # Return a the cookbook name, and version number separated by a dash
    # @return [String]
    def to_s
      raw_cookbook.name
    end

    # Get a short description of the cookbook.
    # @return [String]
    def description
      metadata.description
    end

    # Get the maintainer of the cookbook
    # @return [String]
    def maintainer
      metadata.maintainer
    end

    # Get the path to the cookbook on the file system
    # @return [String]
    def path
      raw_cookbook.path
    end

    # Get a URL friendly version of the cookbook version
    # @return [String]
    def web_friendly_version
      version.gsub('.', '_')
    end

    # Get any dependencies that this cookbook may have
    # @return [Hash] cookbook_name => version_requirement
    def dependencies
      metadata.dependencies
    end

    # Get a list of platforms this cookbook can run on
    # @return [Array<String>]
    def platforms
      metadata.platforms.keys
    end

    # Get the path to the README file if one is available
    # @return [String]
    def readme_file
      @readme_file ||= find_file('readme')
    end

    # Get the path to the CHANGELOG file if one is available
    # @return [String]
    def changelog_file
      @changelog_file ||= find_file('changelog')
    end

    # Get the parsed Markdown content of the README
    # @return [String]
    def readme_content
      @readme_content ||= Web::MarkdownParser.parse(readme_file) if readme_file
    end

    # Get the parsed Markdown content of the CHANGELOG
    # @return [String]
    def changelog_content
      @changelog_content ||= Web::MarkdownParser.parse(changelog_file) if changelog_file
    end

    def to_hash
      {
        name:           name,
        version:        version,
        description:    description,
        maintainer:     maintainer,
        download_url:   cookbook_download_path(self),
        url:            cookbook_path(self),
        downloaded_at:  downloaded_at,
        download_date:  download_date,
        platforms:      normalized_platforms
      }
    end

    def to_json(opts = {})
      to_hash.to_json
    end

    # Get the time at which this cookbook was downloaded by Minimart.
    # @return [Time]
    def downloaded_at
      download_metadata.downloaded_at
    end

    # Get a human friendly downlaod date of this cookbook (ex. January 1st, 2015)
    # @return [String]
    def download_date
      return unless downloaded_at
      downloaded_at.strftime('%B %d, %Y')
    end

    def <=>(other)
      Semverse::Version.new(version) <=> Semverse::Version.new(other.version)
    end

    def satisfies_requirement?(constraint)
      Semverse::Constraint.new(constraint).satisfies?(version)
    end

    def normalized_platforms
      return {'question' => 'Not Specified'} if platforms.nil? || platforms.empty?

      platforms.inject({}) do |memo, platform|
        memo[platform_icon(platform)] = platform.capitalize
        memo
      end
    end

    protected

    attr_reader :raw_cookbook

    def metadata
      raw_cookbook.metadata
    end

    def find_file(name)
      Dir.glob(File.join(path, '*')).find do |file|
        File.basename(file, File.extname(file)) =~ /\A#{name}\z/i
      end
    end

    def download_metadata
      @download_metadata ||= Minimart::Mirror::DownloadMetadata.new(self.path)
    end
  end
end
