require 'ridley'

module Minimart
  class Web

    attr_reader :inventory_directory
    attr_reader :web_directory
    attr_reader :endpoint
    attr_reader :universe

    def initialize(opts = {})
      @inventory_directory = File.expand_path(opts[:inventory_directory])
      @web_directory       = File.expand_path(opts[:web_directory])
      @endpoint            = opts[:endpoint]
      @universe            = {}
    end

    def execute!
      FileUtils.mkdir_p web_directory
      FileUtils.mkdir_p web_cookbook_base_path

      each_cookbook do |cookbook|
        make_cookbook_directory(cookbook)
        generate_archive_file(cookbook)
        add_cookbook_to_universe(cookbook)
      end

      write_universe_file
    end

    private

    def each_cookbook(&block)
      inventory_cookbooks.each do |cookbook_path|
        block.call(cookbook_from_path(cookbook_path))
      end
    end

    def cookbook_from_path(path)
      Ridley::Chef::Cookbook.from_path(path)
    end

    def inventory_cookbooks
      Utils::FileHelper.find_cookbooks_in_directory(inventory_directory)
    end

    def web_cookbook_base_path
      @web_cookbook_base_path ||= File.join(web_directory, '/cookbooks')
    end

    def make_cookbook_directory(cookbook)
      FileUtils.mkdir_p(web_cookbook_path(cookbook.cookbook_name))
    end

    def web_cookbook_path(cookbook_name)
      File.join(web_cookbook_base_path, cookbook_name)
    end

    def generate_archive_file(cookbook)
      FileUtils.mkdir_p(archive_path(cookbook))
      Utils::Archive.pack_archive(inventory_directory, cookbook.name, archive_name(cookbook))
    end

    def archive_path(cookbook)
      File.join(web_cookbook_path(cookbook.cookbook_name), friendly_version(cookbook))
    end

    def archive_name(cookbook)
      File.join(archive_path(cookbook), "#{cookbook.name}.tar.gz")
    end

    def add_cookbook_to_universe(cookbook)
      universe[cookbook.cookbook_name] ||= {}
      universe[cookbook.cookbook_name][cookbook.version.to_s] = {
        location_type:  :uri,
        location_path:  archive_url(cookbook),
        download_url:   archive_url(cookbook),
        dependencies:   cookbook.metadata.dependencies
      }
    end

    def archive_url(cookbook)
      Utils::Http.build_url(endpoint, "cookbooks/#{cookbook.cookbook_name}/#{friendly_version(cookbook)}/#{cookbook.name}.tar.gz")
    end

    def write_universe_file
      File.open(File.join(web_directory, 'universe'), 'w+') do |f|
        f.write(universe.to_json)
      end
    end

    def friendly_version(cookbook)
      cookbook.version.gsub('.', '_')
    end

  end
end
