require 'spec_helper'

describe Minimart::Mirror::LocalStore do

  subject { Minimart::Mirror::LocalStore.new(test_directory) }

  describe '::new' do
    context 'when a cookbook is found in the path' do
      subject { Minimart::Mirror::LocalStore.new('spec/fixtures') }

      it 'should add the cookbook to the store' do
        expect(subject.installed?('sample_cookbook', '1.2.3')).to eq true
      end
    end
  end

  describe "#add_cookbook_from_path" do
    let(:sample_cookbook_path) { 'spec/fixtures/sample_cookbook' }

    it 'should copy the sample cookbook' do
      subject.add_cookbook_from_path(sample_cookbook_path)
      new_cookbook_path = File.join(test_directory, 'sample_cookbook-1.2.3')
      expect(Dir.exists?(new_cookbook_path)).to eq true
    end

    it 'should add the cookbook to the local store' do
      subject.add_cookbook_from_path(sample_cookbook_path)
      expect(subject.installed?('sample_cookbook', '1.2.3')).to eq true
    end

    it 'should store any download metadata' do
      expect_any_instance_of(Minimart::Mirror::DownloadMetadata).to receive(:write).with('my' => 'data')
      subject.add_cookbook_from_path(sample_cookbook_path, 'my' => 'data')
    end

    it 'should store the metadata in the proper path' do
      subject.add_cookbook_from_path(sample_cookbook_path)
      expect(File.exists?(File.join(test_directory, 'sample_cookbook-1.2.3', '.minimart.json'))).to eq true
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
