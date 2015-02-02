require 'spec_helper'

describe Minimart::Configuration do

  describe '#output' do
    subject { Minimart::Configuration.output }
    it { is_expected.to be_a Minimart::Output }
  end

  describe '#chef_server_config' do
    subject { Minimart::Configuration.chef_server_config }
    it { is_expected.to eq({ssl: {verify: true}}) }

    context 'when a value is set' do
      let(:conf) { {'client_name' => 'berkshelf', 'client_key' => 'key_path'} }

      before(:each) { Minimart::Configuration.chef_server_config = conf }
      after(:each) { Minimart::Configuration.chef_server_config = nil }

      it { is_expected.to include conf }
    end
  end

  describe '#github_config' do
    subject { Minimart::Configuration.github_config }
    it { is_expected.to eq({:connection_options=>{:ssl=>{:verify=>true}}}) }

    context 'when a value is set' do
      let(:conf) { {'organization' => 'org', 'api_endpoint' => 'api'} }

      before(:each) { Minimart::Configuration.github_config = conf }
      after(:each) { Minimart::Configuration.github_config = nil }

      it { is_expected.to include conf }
    end
  end

  describe '#verify_ssl' do
    after(:each) { Minimart::Configuration.verify_ssl = nil }

    subject { Minimart::Configuration.verify_ssl }
    it { is_expected.to eq true }

    context 'when set to false' do
      subject { Minimart::Configuration.verify_ssl = false }
      it { is_expected.to eq false }
    end

    context 'when set to true' do
      subject { Minimart::Configuration.verify_ssl = true }
      it { is_expected.to eq true }
    end
  end
end
