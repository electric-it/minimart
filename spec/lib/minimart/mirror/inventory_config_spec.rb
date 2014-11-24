require 'spec_helper'

describe Minimart::Mirror::InventoryConfig do

  let(:config_file_path) { 'spec/fixtures/sample_inventory.yml' }

  describe '::new' do
    subject { Minimart::Mirror::InventoryConfig.new(config_file_path) }

    it 'should parse the provided yml file' do
      expect(subject.config_contents.keys).to include 'https://supermarket.getchef.com'
    end

    context 'when the inventory config file does not exist' do
      it 'should raise the proper exception' do
        expect {
          Minimart::Mirror::InventoryConfig.new('not_a_real_config.yml')
        }.to raise_error(Minimart::Mirror::InvalidInventoryError)
      end
    end
  end

  describe '#sources' do
    subject { Minimart::Mirror::InventoryConfig.new(config_file_path) }

    let(:sources) { subject.sources }

    it 'should create sources for the correct endpoints' do
      source_urls = subject.sources.map(&:url)
      expect(source_urls).to include 'https://supermarket.getchef.com'
    end
  end

end
