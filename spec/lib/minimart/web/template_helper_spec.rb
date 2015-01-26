require 'spec_helper'

describe Minimart::Web::TemplateHelper do
  let(:klass) do
    k = Class.new
    k.extend(Minimart::Web::TemplateHelper)
    k
  end

  describe '#platform_icon' do
    describe 'amazon' do
      subject { klass.platform_icon('amazon') }
      it { is_expected.to eq 'aws' }
    end

    describe 'centos' do
      subject { klass.platform_icon('centos') }
      it { is_expected.to eq 'centos' }
    end

    describe 'debian' do
      subject { klass.platform_icon('debian') }
      it { is_expected.to eq 'debian' }
    end

    describe 'fedora' do
      subject { klass.platform_icon('fedora') }
      it { is_expected.to eq 'fedora' }
    end

    describe 'freebsd' do
      subject { klass.platform_icon('freebsd') }
      it { is_expected.to eq 'freebsd' }
    end

    describe 'linuxmint' do
      subject { klass.platform_icon('linuxmint') }
      it { is_expected.to eq 'linux-mint' }
    end

    describe 'mac_os_x' do
      subject { klass.platform_icon('mac_os_x') }
      it { is_expected.to eq 'apple' }
    end

    describe 'oracle' do
      subject { klass.platform_icon('oracle') }
      it { is_expected.to eq 'oracle' }
    end

    describe 'raspbian' do
      subject { klass.platform_icon('raspbian') }
      it { is_expected.to eq 'raspberrypi' }
    end

    describe 'redhat' do
      subject { klass.platform_icon('redhat') }
      it { is_expected.to eq 'redhat' }
    end

    describe 'solaris' do
      subject { klass.platform_icon('solaris') }
      it { is_expected.to eq 'solaris' }
    end

    describe 'suse' do
      subject { klass.platform_icon('suse') }
      it { is_expected.to eq 'suse' }
    end

    describe 'ubuntu' do
      subject { klass.platform_icon('ubuntu') }
      it { is_expected.to eq 'ubuntu' }
    end

    describe 'windows' do
      subject { klass.platform_icon('windows') }
      it { is_expected.to eq 'windows' }
    end

    describe 'unknown' do
      subject { klass.platform_icon('made-up-os') }
      it { is_expected.to eq 'laptop' }
    end
  end
end
