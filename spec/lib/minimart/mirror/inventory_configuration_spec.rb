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
    it 'should build any cookbooks for any listed versions' do
      expect(subject.requirements.any? { |c| c.version_requirement == '~> 5.6.1' }).to eq true
    end

    it 'should build cookbooks for any git branches' do
      expect(subject.requirements.any? { |c| c.respond_to?(:branch) && c.branch == 'windows' }).to eq true
    end

    it 'should build cookbooks for any git tags' do
      expect(subject.requirements.any? { |c| c.respond_to?(:tag) && c.tag == 'v5.2.0' }).to eq true
    end

    it 'should build cookbooks for any git refs' do
      expect(subject.requirements.any? { |c| c.respond_to?(:ref) && c.ref == 'git-ref-sha' }).to eq true
    end

    it 'should build any cookbooks for local paths' do
      expect(subject.requirements.any? { |c| c.respond_to?(:path) && c.path == 'spec/fixtures/sample_cookbook' }).to eq true
    end
  end

end
