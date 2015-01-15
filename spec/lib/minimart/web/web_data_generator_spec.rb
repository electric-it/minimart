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

  describe '#generate' do
    it 'should return the data structure' do
      result = subject.generate
      expect(result['sample_cookbook']).to include an_instance_of(Minimart::Cookbook)
    end

    it 'should generate a data.json file in the directory' do
      subject.generate
      expect(File.exists?(data_path)).to eq true
    end

    it 'should include data about any cookbooks in the json file' do
      subject.generate
      json = JSON.parse(File.open(data_path).read)
      expect(json['sample_cookbook'].first).to include('version' => '1.2.3')
    end
  end

end
