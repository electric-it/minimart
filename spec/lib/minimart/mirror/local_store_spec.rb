require 'spec_helper'

describe Minimart::Mirror::LocalStore do

  subject { Minimart::Mirror::LocalStore.new(test_directory) }

  describe "#add_cookbook_from_directory" do
    let(:sample_cookbook_path) { 'spec/fixtures/sample_cookbook' }

    before(:each) do
      subject.add_cookbook_from_directory(sample_cookbook_path)
    end

    it 'should copy the sample cookbook' do
      new_cookbook_path = File.join(test_directory, 'sample_cookbook-1.2.3')
      expect(Dir.exists?(new_cookbook_path)).to eq true
    end

    it 'should add the cookbook to the local store' do
      expect(subject.installed?('sample_cookbook', '1.2.3')).to eq true
    end
  end

  describe '#installed?' do
    context 'when a cookbook is installed' do
      before(:each) do
        subject.add_cookbook_to_store('sample_cookbook', '1.2.3')
      end

      it 'should return true for a matching version' do
        expect(subject.installed?('sample_cookbook', '1.2.3')).to eq true
      end

      it 'should return false for a non-matching version' do
        expect(subject.installed?('sample_cookbook', '10.0.0')).to eq false
      end
    end

    context 'when a cookbook is not installed' do
      it 'should return false' do
        expect(subject.installed?('sample_cookbook', '1.2.3')).to eq false
      end
    end
  end

end
