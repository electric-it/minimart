require 'rspec'
require 'pry'
require 'webmock/rspec'

require 'minimart'

RSpec.configure do |config|
  config.mock_with :rspec
end
