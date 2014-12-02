require 'rspec'
require 'pry'
require 'webmock/rspec'

require 'minimart'

Dir['spec/support/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.include Minimart::RSpecSupport::FileSystem

  config.before(:each) { make_test_directory }
  config.after(:each) { remove_test_directory }

  config.mock_with :rspec
end
