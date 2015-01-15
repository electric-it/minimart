require 'spec_helper'

describe Minimart::Web::WebDataGenerator do

  let(:inventory_directory) { 'spec/fixtures/' }
  let(:directory) { test_directory }
  let(:data_path) { File.join(directory, 'data.json') }

  subject do
    Minimart::Web::WebDataGenerator.new(
      inventory_directory: inventory_directory,
      web_directory: directory)
  end

  describe '::new' do
    pending
  end

  describe '::to_json' do
    pending
  end

  describe '::values' do
    pending
  end

  describe '::[]' do
    pending
  end

end
