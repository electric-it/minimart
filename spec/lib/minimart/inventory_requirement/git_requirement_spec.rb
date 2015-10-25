require 'spec_helper'
require 'minimart/inventory_requirement/base_requirement'
require 'minimart/inventory_requirement/git_requirement'

describe Minimart::InventoryRequirement::GitRequirement do

  let(:requirement) do
    Minimart::InventoryRequirement::GitRequirement.new(
      'sample_cookbook',
      branch: 'new-feature-branch')
  end

  before(:each) do
    allow_any_instance_of(Minimart::Download::GitRepository).to receive(:fetch).
      with('new-feature-branch').
      and_yield('spec/fixtures/sample_cookbook')
  end

  describe '::new' do
    it 'should set the name' do
      expect(requirement.name).to eq 'sample_cookbook'
    end

    context 'when a branch is provided' do
      it 'should set the branch' do
        expect(requirement.branch).to eq 'new-feature-branch'
      end
    end

    context 'when a ref is provided' do
      it 'should set the sha' do
        cookbook = Minimart::InventoryRequirement::GitRequirement.new('sample_cookbook', ref: 'SHA')
        expect(cookbook.ref).to eq 'SHA'
      end
    end

    context 'when a tag is provided' do
      it 'should set the tag' do
        cookbook = Minimart::InventoryRequirement::GitRequirement.new('sample_cookbook', tag: 'v1.0.0')
        expect(cookbook.tag).to eq 'v1.0.0'
      end
    end
  end

  describe '#explicit_location?' do
    subject { requirement.explicit_location? }
    it { is_expected.to eq true }
  end

  describe '#requirements' do
    before(:each) { requirement.fetch_cookbook }
    subject { requirement.requirements }
    it { is_expected.to_not eq('yum' => '> 3.0.0') }
  end

  describe '#matching_source?' do
    let(:metadata) do
      { 'source_type' => 'git', 'commitish_type' => 'branch', 'commitish' => 'new-feature-branch'}
    end

    subject { requirement.matching_source?(metadata) }

    it { is_expected.to eq true }

    describe 'when the source type is not matching' do
      before(:each) { metadata['source_type'] = 'local_path' }

      it { is_expected.to eq false }
    end

    describe 'when the commitish type is not matching' do
      before(:each) { metadata['commitish_type'] = 'tag' }

      it { is_expected.to eq false }
    end

    describe 'when the commitish is not matching' do
      before(:each) { metadata['commitish'] = 'another-branch' }

      it { is_expected.to eq false }

      context 'when the commitish type is a ref' do
        before(:each) do
          allow(requirement).to receive('commitish_type').and_return 'ref'
          metadata['commitish_type'] = 'ref'
        end

        it { is_expected.to eq true }
      end
    end
  end
end
