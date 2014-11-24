require 'spec_helper'

describe Minimart::Mirror::Source do

  let(:url) { 'https://fakechefsupermarket.com' }
  let(:raw_cookbooks) do
    {
      "mysql" => { "versions" => ["3.5", "4.0"] },
      "yum"   => { "versions" => ["3.4"] }
    }
  end

  subject { Minimart::Mirror::Source.new(url, raw_cookbooks) }

  describe '::new' do
    it 'should properly assign the url' do
      expect(subject.url).to eq url
    end

    it 'should build the proper cookbooks' do
      cookbooks = subject.cookbooks
      expect(cookbooks.any? { |c| c.name == 'mysql' && c.version = '3.5' }).to eq true
      expect(cookbooks.any? { |c| c.name == 'mysql' && c.version = '4.0' }).to eq true
      expect(cookbooks.any? { |c| c.name == 'yum' && c.version = '3.4' }).to eq true
    end

    it 'should build a universe' do
      expect(subject.universe).to be_a Minimart::Mirror::Universe
    end

    it 'should pass the proper url to the universe' do
      expect(subject.universe.base_url).to eq url
    end
  end

  describe '#download_explicit_dependencies' do
    let(:mysql_dependency) { {name: 'mysql', version: '4.5'} }
    let(:yum_dependency) { {name: 'yum', version: '5.0'} }
    let(:block) { Proc.new { true } }

    before(:each) do
      subject.cookbooks = [mysql_dependency, yum_dependency]
    end

    it 'should download the dependencies' do
      expect(subject).to receive(:download_cookbook).with mysql_dependency, &block
      expect(subject).to receive(:download_cookbook).with yum_dependency, &block
      subject.download_explicit_dependencies(&block)
    end
  end

  describe '#download_cookbook' do
    let(:mock_cookbook) do
      Hashie::Mash.new(
        name: 'mysql',
        version: '3.5.0',
        download_url: 'http://sprkmrkt.com/mysql')
    end

    let(:mock_archive) { double('archive') }
    let(:block) { Proc.new { true } }

    before(:each) do
      allow(subject.universe).to receive(:find_cookbook).and_return mock_cookbook
    end

    it 'should download the cookbook from the source' do
      expect(Minimart::Utils::Http).to receive(:get_binary).with(anything, mock_cookbook.download_url)
      subject.download_cookbook mock_cookbook, &block
    end

    it 'should pass the cookbook and archive to the block passed in' do
      allow(Minimart::Utils::Http).to receive(:get_binary).and_return mock_archive
      expect(block).to receive(:call).with(mock_cookbook, mock_archive)
      subject.download_cookbook mock_cookbook, &block
    end
  end

  describe '#resolve_dependency' do
    pending
  end
end
