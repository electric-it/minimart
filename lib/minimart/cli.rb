require 'thor'

require 'minimart'
require 'minimart/commands/mirror'

module Minimart
  # The command line interface for Minimart.
  class Cli < Thor
    include Thor::Actions

    DEFAULT_INVENTORY_CONFIG    = './inventory.yml'
    DEFAULT_INVENTORY_DIRECTORY = './inventory'
    DEFAULT_WEB_DIRECTORY       = './web'

    desc 'init', 'Begin a new Minimart.'
    option :inventory_config, default: DEFAULT_INVENTORY_CONFIG
    def init
      create_file options[:inventory_config] do
<<-YML
# sources:
#   - "https://supermarket.getchef.com"
# cookbooks:
#   cookbook-name:
#     versions:
#       - "~> 4.0.2"
#       - "> 5.0.0"
#     git:
#       location: url | path
#       branches:
#         - a_branch_name
#       refs:
#         - SHA

YML
      end
    end

    desc 'mirror', 'Mirror a listing of cookbooks.'
    option :inventory_config, default: DEFAULT_INVENTORY_CONFIG
    option :inventory_directory, default: DEFAULT_INVENTORY_DIRECTORY
    def mirror
      Minimart::Commands::Mirror.new(options).execute!
    end

    desc 'web', 'Generate a web interface to download mirrored cookbooks'
    option :inventory_directory, aliases: :id, default: DEFAULT_INVENTORY_DIRECTORY
    option :web_directory,       aliases: :wd, default: DEFAULT_WEB_DIRECTORY, required: true
    option :endpoint,            aliases: :e, required: true
    def web
      Minimart::Commands::Web.new(options).execute!
    end

  end
end
