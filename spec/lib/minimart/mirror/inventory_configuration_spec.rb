require 'spec_helper'

describe Minimart::Mirror::InventoryConfiguration do

  let(:config_file_path) { 'spec/fixtures/sample_inventory.yml' }

  describe '::new' do
    pending do
      subject { Minimart::Mirror::InventoryConfiguration.new(config_file_path) }

      it 'should parse the provided yml file' do
        expect(subject.sources).to include 'https://supermarket.getchef.com'
      end

      context 'when the inventory config file does not exist' do
        it 'should raise the proper exception' do
          expect {
            Minimart::Mirror::InventoryConfiguration.new('not_a_real_config.yml')
          }.to raise_error(
            Minimart::Mirror::InvalidInventoryError,
            'The inventory configuration file could not be found')
        end
      end
    end
  end

end
