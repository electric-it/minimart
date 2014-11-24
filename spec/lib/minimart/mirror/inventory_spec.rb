require 'spec_helper'

describe Minimart::Mirror::Inventory do

  describe '::new' do
    context 'when an inventory config file is not passed' do
      it 'should raise the proper exception' do
        expect {
          Minimart::Mirror::Inventory.new
        }.to raise_error(ArgumentError, 'missing required :inventory_config option')
      end
    end

    context 'when the inventory config file does not exist' do
      it 'should raise the proper exception' do
        expect {
          Minimart::Mirror::Inventory.new(inventory_config: 'not_a_real_config')
        }.to raise_error(Minimart::Mirror::InvalidInventoryError)
      end
    end
  end

  describe '#build' do
    let(:inventory_config) { 'spec/fixtures/sample_inventory.yml' }

    subject do
      Minimart::Mirror::Inventory.new(inventory_config: inventory_config)
    end
  end

end
