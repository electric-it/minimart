require 'spec_helper'

describe Minimart::Utils::Http do
  describe '::get_json' do
    pending
  end

  describe '::get' do
    pending
  end

  describe '::get_binary' do
    pending
  end

  describe '::build_url' do
    context 'when no protocol is provided' do
      subject { described_class.build_url('example.com') }
      it  { is_expected.to eq 'http://example.com' }
    end

    context 'when a protocol is provided' do
      subject { described_class.build_url('git://example.com') }
      it  { is_expected.to eq 'git://example.com' }
    end

    context 'when a sub url is provided' do
      subject { described_class.build_url('http://example.com', 'path') }
      it { is_expected.to eq 'http://example.com/path' }
    end

    context 'when the path has a leading slash' do
      subject { described_class.build_url('http://example.com/', '/path') }
      it { is_expected.to eq 'http://example.com/path' }
    end
  end
end
