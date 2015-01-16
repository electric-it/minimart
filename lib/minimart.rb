require 'ridley'
require 'json'
require 'fileutils'

module Minimart
  require 'minimart/version'

  require 'minimart/configuration'
  require 'minimart/error'

  require 'minimart/utils/archive'
  require 'minimart/utils/file_helper'
  require 'minimart/utils/http'

  require 'minimart/web/template_helper'
  require 'minimart/web/cookbooks'

  def self.root_path
    File.dirname(__FILE__)
  end
end
