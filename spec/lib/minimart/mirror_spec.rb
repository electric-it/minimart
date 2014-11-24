require 'spec_helper'

describe Minimart::Mirror do

  let(:inventory_directory) { './inventory' }
  let(:inventory_config_path) { 'spec/fixtures/sample_inventory.yml' }

  subject do
    Minimart::Mirror.new(
    inventory_directory: inventory_directory,
    inventory_config: inventory_config_path)
  end

  describe '::new' do
    it 'should set the inventory directory' do
      expect(subject.inventory_directory).to eq inventory_directory
    end

    it 'should build an inventory config' do
      expect(subject.inventory_config).to be_a Minimart::Mirror::InventoryConfig
    end

    it 'should pass the inventory config file path' do
      expect(subject.inventory_config.inventory_config_path).to eq inventory_config_path
    end
  end

  describe '::execute' do
    let(:builder) { double('builder', build!: nil) }

    it 'should build an inventory' do
      expect(Minimart::Mirror::InventoryBuilder).to receive(:new).and_return builder
      subject.execute!
    end
  end
end
