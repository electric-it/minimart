require 'spec_helper'

describe Minimart::Configuration do

  describe '#output' do
    subject { Minimart::Configuration.output }
    it { is_expected.to be_a Minimart::Output }
  end

  describe '#chef_server_config' do
    subject { Minimart::Configuration.chef_server_config }
    it { is_expected.to eq({}) }

    context 'when a value is set' do
      let(:conf) { {'client_name' => 'berkshelf', 'client_key' => 'key_path'} }

      before(:each) { Minimart::Configuration.chef_server_config = conf }
      after(:each) { Minimart::Configuration.chef_server_config = nil }

      it { is_expected.to eq conf }
    end
  end

  describe '#github_config' do
    subject { Minimart::Configuration.github_config }
    it { is_expected.to eq({}) }

    context 'when a value is set' do
      let(:conf) { {'organization' => 'org', 'api_endpoint' => 'api'} }

      before(:each) { Minimart::Configuration.github_config = conf }
      after(:each) { Minimart::Configuration.github_config = nil }

      it { is_expected.to eq conf }
    end
  end
end
