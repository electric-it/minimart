require 'spec_helper'

describe Minimart::InventoryRequirement::GitRequirement do

  subject do
    Minimart::InventoryRequirement::GitRequirement.new(
      'sample_cookbook',
      branch: 'new-feature-branch')
  end

  before(:each) do
    allow_any_instance_of(Minimart::Download::GitRepository).to receive(:fetch).
      with('new-feature-branch').
      and_return('spec/fixtures/sample_cookbook')
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

  describe '#location_specification?' do
    it 'should return true' do
      expect(subject.location_specification?).to eq true
    end
  end

  describe '#requirements' do
    before(:each) { subject.fetch_cookbook }

    it 'should return the requirements specified in the cookbook metadata' do
      expect(subject.requirements).to eq 'yum' => '> 3.0.0'
    end
  end

  describe '#cookbook_info' do
    before(:each) { subject.fetch_cookbook }

    it 'should return relevant information' do
      info = subject.cookbook_info
      expect(info.name).to eq 'sample_cookbook'
      expect(info.version).to eq '1.2.3'
      expect(info.dependencies).to eq 'yum' => '> 3.0.0'
    end
  end

  describe '#cookbook_path' do
    before(:each) { subject.fetch_cookbook }

    it 'should return the path to the cookbook' do
      expect(subject.cookbook_path.to_s).to match 'spec/fixtures/sample_cookbook'
    end
  end
end
