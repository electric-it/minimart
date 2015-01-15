begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue LoadError
end

require 'rspec'
require 'fakefs/safe'
require 'pry'
require 'vcr'
require 'webmock/rspec'

require 'minimart'

Dir['spec/support/*.rb'].each { |f| require File.expand_path(f) }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include Minimart::RSpecSupport::FileSystem

  config.before(:each) { make_test_directory }
  config.after(:each) { remove_test_directory }

  config.mock_with :rspec

  Minimart::Configuration.output = StringIO.new
end
