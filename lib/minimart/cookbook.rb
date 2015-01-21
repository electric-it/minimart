require 'ridley'
require 'semverse'

require 'minimart/web/markdown_parser'

module Minimart
  class Cookbook
    include Web::TemplateHelper

    def self.from_path(path)
      new (Ridley::Chef::Cookbook.from_path(path))
    end

    def initialize(raw_cookbook)
      @raw_cookbook = raw_cookbook
    end

    def name
      raw_cookbook.cookbook_name
    end

    def version
      raw_cookbook.version
    end

    # Return a the cookbook name, and version number separated by a dash
    def to_s
      raw_cookbook.name
    end

    def description
      metadata.description
    end

    def maintainer
      metadata.maintainer
    end

    def path
      raw_cookbook.path
    end

    def web_friendly_version
      version.gsub('.', '_')
    end

    def dependencies
      metadata.dependencies
    end

    def readme_file
      @readme_file ||= find_file('readme')
    end

    def changelog_file
      @changelog_file ||= find_file('changelog')
    end

    def readme_content
      @readme_content ||= Web::MarkdownParser.parse(readme_file) if readme_file
    end

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
        download_date:  download_date
      }
    end

    def to_json(opts = {})
      to_hash.to_json
    end

    def downloaded_at
      download_metadata.downloaded_at
    end

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
