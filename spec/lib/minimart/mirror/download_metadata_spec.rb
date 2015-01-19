require 'spec_helper'

describe Minimart::Mirror::DownloadMetadata do

  subject do
    Minimart::Mirror::DownloadMetadata.new('spec/fixtures/sample_cookbook')
  end

  before(:each) { activate_fake_fs }
  after(:each) { deactivate_fake_fs }

  describe '::new' do
    it 'should assign #path_to_cookbook' do
      expect(subject.path_to_cookbook).to eq 'spec/fixtures/sample_cookbook'
    end

    context 'when metadata for that file has already been written' do
      let(:metadata) { { 'fake_data' => 'info' } }

      before(:each) do
        File.open('spec/fixtures/sample_cookbook/.minimart.json', 'w+') do |f|
          f.write(metadata.to_json)
        end
      end

      it 'should parse the metadata' do
        expect(subject.metadata).to eq metadata
      end
    end
  end

  describe '#write' do
    let(:file_contents) do
      JSON.parse(File.open('spec/fixtures/sample_cookbook/.minimart.json').read)
    end

    before(:each) { subject.write({'source' => 'example.com'}) }

    it 'should write any of the provided content to the file' do
      expect(file_contents['source']).to eq 'example.com'
    end

    it 'should write the downloaded at timestamp' do
      expect(file_contents.keys).to include 'downloaded_at'
    end

    it 'should store any of the metadata as an instance variable' do
      expect(subject.metadata).to include(
        'source'        => 'example.com',
        'downloaded_at' => an_instance_of(String))
    end
  end

  describe '#downloaded_at' do
    context 'when no downloaded_at is in the metadata' do
      subject { Minimart::Mirror::DownloadMetadata.new('new-cookbook') }

      it 'should return nil' do
        expect(subject.downloaded_at).to be_nil
      end
    end

    context 'when the downloaded_at has been set' do
      before(:each) { subject.write }

      it 'should parse the time' do
        expect(subject.downloaded_at).to be_a Time
      end
    end
  end

end
