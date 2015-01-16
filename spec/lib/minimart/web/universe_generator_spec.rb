require 'spec_helper'
require 'minimart/web/universe_generator'
require 'minimart/web/cookbooks'
require 'minimart/cookbook'

describe Minimart::Web::UniverseGenerator do

  before(:each) { activate_fake_fs }
  after(:each) { deactivate_fake_fs }

  let(:web_directory) { '/web' }
  let(:endpoint) { 'example.com' }

  let(:cookbook) do
    instance_double(Minimart::Cookbook,
      name: 'sample_cookbook',
      version: '1.2.3',
      web_friendly_version: '1_2_3',
      dependencies: {'mysql' => '> 0.0'},
      path: Pathname.new('/spec/fixtures/sample_cookbook'),
      to_s: 'sample_cookbook-1.2.3')
  end

  let(:cookbooks) do
    instance_double(Minimart::Web::Cookbooks, individual_cookbooks: [cookbook])
  end

  subject do
    Minimart::Web::UniverseGenerator.new(
      web_directory: web_directory,
      endpoint:      endpoint,
      cookbooks:     cookbooks)
  end

  describe '::new' do
    it 'should assign #web_directory' do
      expect(subject.web_directory).to eq web_directory
    end

    it 'should assign #endpoint' do
      expect(subject.endpoint).to eq endpoint
    end

    it 'should assign #cookbooks' do
      expect(subject.cookbooks).to eq cookbooks
    end

    it 'should build an empty universe' do
      expect(subject.universe.empty?).to eq true
    end
  end

  describe '#generate' do
    before(:each) do
      allow(Minimart::Utils::Archive).to receive(:pack_archive)
    end

    it 'should make a cookbook_files directory in the web directory' do
      subject.generate
      expect(Dir.exists?('/web/cookbook_files')).to eq true
    end

    it 'should make a sub-directory for any cookbooks provided' do
      subject.generate
      expect(Dir.exists?('/web/cookbook_files/sample_cookbook')).to eq true
    end

    it 'should make a sub-directory for any versions of cookbooks provided' do
      subject.generate
      expect(Dir.exists?('/web/cookbook_files/sample_cookbook/1_2_3')).to eq true
    end

    it 'should generate an archive for the cookbook in the correct path' do
      expect(Minimart::Utils::Archive).to receive(:pack_archive).with(
        '/spec/fixtures',
        'sample_cookbook',
        '/web/cookbook_files/sample_cookbook/1_2_3/sample_cookbook-1.2.3.tar.gz')

      subject.generate
    end

    it 'should write a universe file in the proper directory' do
      subject.generate
      expect(File.exists?('/web/universe.json')).to eq true
    end

    describe 'universe contents' do
      let(:universe_contents) { JSON.parse(File.open('/web/universe.json').read) }
      let(:cookbook_info) { universe_contents['sample_cookbook']['1.2.3'] }

      before(:each) { subject.generate }

      it 'should give the cookbook the proper location type' do
        expect(cookbook_info['location_type']).to eq 'uri'
      end

      it 'should give the cookbook the proper location path' do
        expect(cookbook_info['location_path']).to eq 'http://example.com/cookbook_files/sample_cookbook/1_2_3/sample_cookbook-1.2.3.tar.gz'
      end

      it 'should give the cookbook the proper download url' do
        expect(cookbook_info['download_url']).to eq 'http://example.com/cookbook_files/sample_cookbook/1_2_3/sample_cookbook-1.2.3.tar.gz'
      end

      it 'should include any dependencies' do
        expect(cookbook_info['dependencies']).to eq('mysql' => '> 0.0')
      end
    end
  end

end
