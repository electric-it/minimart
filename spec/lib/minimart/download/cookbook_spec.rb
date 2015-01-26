require 'spec_helper'

describe Minimart::Download::Cookbook do

  let(:archive) { File.open('spec/fixtures/sample_cookbook.tar.gz') }

  let(:cookbook) do
    Minimart::Mirror::SourceCookbook.new(
      location_type:        'opscode',
      location_path:        'http://supermarket.chef.io',
      name:                 'sample',
      version:              '0.1.0',
      web_friendly_version: '0_1_0')
  end

  subject do
    Minimart::Download::Cookbook.new(cookbook)
  end

  describe '::fetch' do
    context 'when the location type provided is not recognized' do
      let(:cookbook) do
        Minimart::Mirror::SourceCookbook.new('location_type' => 'not-real')
      end

      it 'should raise an error' do
        expect {
          subject.fetch
        }.to raise_error Minimart::Error::UnknownLocationType
      end
    end

    context 'supermarket cookbook' do
      let(:url) { 'http://supermarket.chef.io/cookbooks/sample/versions/0_1_0' }
      let(:file_path) { "#{url}.tar.gz" }

      let!(:details_request) do
        stub_request(:get, url).to_return(status: 200, body: {file: file_path}.to_json)
      end

      let!(:file_request) do
        stub_request(:get, file_path).to_return(status: 200, body: archive)
      end

      it 'should request the file location' do
        subject.fetch
        expect(details_request).to have_been_requested
      end

      it 'should actually download the file' do
        subject.fetch
        expect(file_request).to have_been_requested
      end

      it 'should extract the downloaded archive' do
        expect(Minimart::Utils::Archive).to receive(:extract_archive)
        subject.fetch
      end
    end

    context 'uri cookbook' do
      let!(:request) do
        stub_request(:get, cookbook.location_path).to_return(status: 200, body: archive)
      end

      before(:each) { cookbook.location_type = 'uri' }

      it 'should download the archive' do
        subject.fetch
        expect(request).to have_been_requested
      end

      it 'should extract the archive' do
        expect(Minimart::Utils::Archive).to receive(:extract_archive)
        subject.fetch
      end
    end

    context 'chef server cookbook' do
      let(:conf) { {'client_name' => 'berkshelf', 'client_key' => 'key_path'} }

      let(:chef_connection) do
        double('connection', cookbook: double('cookbook', download: true))
      end

      before(:each) do
        Minimart::Configuration.chef_server_config = conf
        cookbook.location_type = 'chef_server'
      end

      after(:each) { Minimart::Configuration.chef_server_config = {} }

      it 'should download the cookbook using Ridley' do
        expect(Ridley).to receive(:open).
          with(conf.merge(server_url: 'http://supermarket.chef.io', ssl: {verify: true})).
          and_yield chef_connection

        subject.fetch
      end
    end

    context 'github cookbook' do
      let(:conf) { {'organization' => 'org', 'api_endpoint' => 'api'} }
      let(:url) { 'http://github.com/org/my_repo' }
      let(:archive_url) { "#{url}.tar.gz" }

      let!(:file_request) do
        stub_request(:get, archive_url).to_return(status: 200, body: archive)
      end

      before(:each) do
        Minimart::Configuration.github_config = conf
        cookbook.location_type = 'github'
        cookbook.location_path = url
      end


      after(:each) { Minimart::Configuration.github_config = nil }

      it 'should build the client with the proper options' do
        expect(Octokit::Client).to receive(:new).with(conf.merge(connection_options: {ssl: {verify: true}})).and_call_original
        allow_any_instance_of(Octokit::Client).to receive(:archive_link).and_return archive_url
        subject.fetch
      end

      it 'should download the cookbook using octokit' do
        expect_any_instance_of(Octokit::Client).to receive(:archive_link).
          with('org/my_repo', ref: 'v0.1.0').
          and_return(archive_url)
        subject.fetch
        expect(file_request).to have_been_requested
      end
    end
  end
end
