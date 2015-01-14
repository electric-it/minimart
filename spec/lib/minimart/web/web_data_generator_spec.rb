require 'spec_helper'

describe Minimart::Web::WebDataGenerator do

  let(:cookbook) do
    instance_double(Minimart::Cookbook,
      name: 'cookbook_name',
      version: '0.0.1',
      description: 'a new cookbook',
      maintainer: 'Mad Glory')
  end

  let(:directory) { test_directory }

  subject do
    Minimart::Web::WebDataGenerator.new(
      cookbooks:     [cookbook],
      web_directory: directory)
  end

  describe '#generate' do
    it 'should return the name of the data file' do
      expect(subject.generate).to match 'data.json'
    end

    it 'should generate a data.json file in the directory' do
      subject.generate
      expect(File.exists?(File.join(directory, 'data.json'))).to eq true
    end

    it 'should include data about any cookbooks' do
      path = subject.generate
      json = JSON.parse(File.open(path).read)
      expect(json.first).to match(
        'name'           => 'cookbook_name',
        'recent_version' => '0.0.1',
        'description'    => 'a new cookbook',
        'maintainer'     => 'Mad Glory')
    end
  end

end
