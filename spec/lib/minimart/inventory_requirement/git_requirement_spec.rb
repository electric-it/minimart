require 'spec_helper'
require 'minimart/inventory_requirement/base_requirement'
require 'minimart/inventory_requirement/git_requirement'

describe Minimart::InventoryRequirement::GitRequirement do

  subject do
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
      expect(subject.name).to eq 'sample_cookbook'
    end

    context 'when a branch is provided' do
      it 'should set the branch' do
        expect(subject.branch).to eq 'new-feature-branch'
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
    it 'should return true' do
      expect(subject.explicit_location?).to eq true
    end
  end

  describe '#requirements' do
    before(:each) { subject.fetch_cookbook }

    it 'should return the requirements specified in the cookbook metadata' do
      expect(subject.requirements).to eq 'yum' => '> 3.0.0'
    end
  end
end
