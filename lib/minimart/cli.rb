require 'minimart'

module Minimart
  class Cli < Thor

    desc 'mirror', 'Mirror a listing of cookbooks.'
    option :inventory_config, default: Minimart::Configuration::DEFAULT_INVENTORY_CONFIG
    option :inventory_directory, default: Minimart::Configuration::DEFAULT_INVENTORY_DIRECTORY
    def mirror
      Minimart::Mirror.new(options).execute!
    end

  end
end
