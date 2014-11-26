require 'rspec'
require 'pry'
require 'webmock/rspec'

require 'minimart'
require 'fakefs/safe'

RSpec.configure do |config|
  config.mock_with :rspec
end
