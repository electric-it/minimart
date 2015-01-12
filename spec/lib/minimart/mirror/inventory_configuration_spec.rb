require 'spec_helper'

describe Minimart::Mirror::InventoryConfiguration do

  let(:config_file_path) { 'spec/fixtures/sample_inventory.yml' }

  subject { Minimart::Mirror::InventoryConfiguration.new(config_file_path) }

  describe '::new' do
    it 'should parse the provided yml file' do
    end

    context 'when the inventory config file does not exist' do
      it 'should raise the proper exception' do
        expect {
          Minimart::Mirror::InventoryConfiguration.new('not_a_real_config.yml')
        }.to raise_error(
          Minimart::Error::InvalidInventoryError,
          'The inventory configuration file could not be found')
      end
    end
  end

  describe '#sources' do
    it 'should build sources' do
      expect(subject.sources).to be_a Minimart::Mirror::Sources
    end

    it 'should build sources with the correct attributes' do
      expect(subject.sources.map &:base_url).to include 'https://supermarket.getchef.com'
    end
  end

  describe '#requirements' do
    it 'should build requirements' do
      expect(subject.requirements).to be_a Minimart::Mirror::InventoryRequirements
    end

    context 'when there are no cookbooks defined in the config file' do
      before(:each) do
        allow_any_instance_of(File).to receive(:read).and_return "sources: \"https://supermarket.getchef.com\""
      end

      it 'should raise an exception' do
        expect {
          subject.requirements
        }.to raise_error Minimart::Error::InvalidInventoryError, 'Minimart could not find any cookbooks defined in the inventory'
      end
    end
  end

end
