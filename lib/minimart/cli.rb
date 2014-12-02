require 'minimart'

module Minimart
  class Cli < Thor
    include Thor::Actions

    desc 'init', 'Begin a new Minimart.'
    def init
      create_file './inventory.yml' do
<<-YML
# sources:
#   - "https://supermarket.getchef.com"
# cookbooks:
#   mysql:
#     versions:
#       - "~> 4.0.2"
#       - "> 5.0.0"
#     git:
#       url:
#       branches:
#         - a_branch_name
#       refs:
#         - SHA
YML
      end
    end

    desc 'mirror', 'Mirror a listing of cookbooks.'
    option :inventory_config, default: Minimart::Configuration::DEFAULT_INVENTORY_CONFIG
    option :inventory_directory, default: Minimart::Configuration::DEFAULT_INVENTORY_DIRECTORY
    def mirror
      Minimart::Mirror.new(options).execute!
    end

  end
end
