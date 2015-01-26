require 'spec_helper'

describe Minimart::InventoryRequirement::LocalPathRequirement do

  let(:requirement) do
    Minimart::InventoryRequirement::LocalPathRequirement.new('sample_cookbook',
      path: 'spec/fixtures/sample_cookbook')
  end

  describe '::new' do
    it 'should set the name' do
      expect(requirement.name).to eq 'sample_cookbook'
    end

    it 'should set the path' do
      expect(requirement.path).to eq 'spec/fixtures/sample_cookbook'
    end
  end

  describe '#explicit_location?' do
    subject { requirement.explicit_location? }
    it { is_expected.to eq true }
  end

  describe '#matching_source?' do
    let(:metadata) { { 'source_type' => 'local_path' } }
    subject { requirement.matching_source?(metadata) }
    it { is_expected.to eq true }

    context 'when the source type is not local path' do
      before(:each) { metadata['source_type'] = 'git' }
      it { is_expected.to eq false }
    end
  end
end
