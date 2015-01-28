require 'json'
require 'fileutils'

module Minimart
  require 'minimart/version'
  require 'minimart/configuration'
  require 'minimart/error'

  require 'minimart/mirror'
  require 'minimart/web'

  def self.root_path
    File.dirname(__FILE__)
  end
end
