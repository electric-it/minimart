require 'spec_helper'

describe Minimart::Utils::Archive do
  describe '::extract_archive' do
    let(:archive) { 'spec/fixtures/sample_cookbook.tar.gz' }

    let(:extracted_readme) do
      File.join(test_directory, 'sample_cookbook', 'README.md')
    end

    it 'should extract the contents of the archive to the passed in dir' do
      Minimart::Utils::Archive.extract_archive(archive, test_directory)
      expect(test_directory_contents).to include extracted_readme
    end
  end

  describe '::pack_archive' do
    let(:path) { File.expand_path('spec/fixtures/sample_cookbook') }
    let(:cookbook) { Minimart::Cookbook.from_path(path) }
    let(:archive) { File.expand_path(File.join(test_directory, 'sample.tar.gz')) }

    before(:each) { Minimart::Utils::Archive.pack_archive(cookbook, archive) }

    it 'should create the archive' do
      expect(File.exists?(archive)).to eq true
    end

    it 'should create a directory of the cookbook name in the top level of the archive' do
      Minimart::Utils::Archive.extract_archive(archive, test_directory)
      expect(Dir.exists?(File.join(test_directory, 'sample_cookbook')))
    end

    it 'should properly compress any files' do
      Minimart::Utils::Archive.extract_archive(archive, test_directory)
      expect(File.exists?(File.join(test_directory, 'sample_cookbook', 'README.md'))).to eq true
    end
  end
end
