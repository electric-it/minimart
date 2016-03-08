require 'thor'

require 'minimart'
require 'minimart/commands/mirror'
require 'minimart/commands/web'

module Minimart
  # The command line interface for Minimart.
  class Cli < Thor
    include Thor::Actions

    DEFAULT_INVENTORY_CONFIG    = './inventory.yml'
    DEFAULT_INVENTORY_DIRECTORY = './inventory'
    DEFAULT_WEB_DIRECTORY       = './web'

    ##
    # Init
    ##
    desc 'init', 'Begin a new Minimart.'
    option :inventory_config, default: DEFAULT_INVENTORY_CONFIG
    # Begin a new Minimart
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

    ##
    # Mirror
    ##
    desc 'mirror', 'Mirror cookbooks specified in an inventory file.'
    option :load_deps,
      type:    :boolean,
      default: false,
      desc:     'This is the flag to allow loading dependencies when cookbooks from inventory are mirrored.'

    option :inventory_config,
      default: DEFAULT_INVENTORY_CONFIG,
      desc:    'The path to the Minimart config file. Minimart will create the file if it does not exist.'

    option :inventory_directory,
      default: DEFAULT_INVENTORY_DIRECTORY,
      desc:    'The path to store any cookbooks downloaded by the mirroring tool.'
    # Mirror cookbooks specified in an inventory file.
    def mirror
      Minimart::Commands::Mirror.new(options).execute!

    rescue Minimart::Error::BaseError => e
      Minimart::Error.handle_exception(e)
    end

    ##
    # Web
    ##
    desc 'web', 'Generate a web interface to download any mirrored cookbooks.'
    option :inventory_directory,
      default: DEFAULT_INVENTORY_DIRECTORY,
      desc:   'Path to the cookbooks downloaded by the mirroring tool.'

    option :web_directory,
      default: DEFAULT_WEB_DIRECTORY,
      desc:    'Path to output the web endpoint of Minimart.'

    option :host,
      aliases: :h,
      required: true,
      desc:     'The web endpoint where Minimart will be hosted. This is required to properly generate the index file to be used by Berkshelf.'

    option :html,
      type:    :boolean,
      default: true,
      desc:    'Flag to determine whether or not to generate HTML output along with the universe endpoint.'

    option :clean_cookbooks,
      default: true,
      desc: 'Flag to determine whether or not existing cookbook packages are deleted and recreated'
    # Generate a web interface to download any mirrored cookbooks.
    def web
      Minimart::Commands::Web.new(options).execute!

    rescue Minimart::Error::BaseError => e
      Minimart::Error.handle_exception(e)
    end

  end
end
