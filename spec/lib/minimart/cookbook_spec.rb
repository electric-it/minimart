require 'spec_helper'

describe Minimart::Cookbook do

  let(:cookbook) do
    Minimart::Cookbook.new('spec/fixtures/sample_cookbook')
  end

  describe '#name' do
    subject { cookbook.name }
    it { is_expected.to eq 'sample_cookbook' }
  end

  describe '#version' do
    subject { cookbook.version }
    it { is_expected.to eq '1.2.3' }
  end

  describe '#to_s' do
    subject { cookbook.to_s }
    it { is_expected.to eq 'sample_cookbook-1.2.3' }
  end

  describe '#description' do
    subject { cookbook.description }
    it { is_expected.to eq 'Installs/Configures sample_cookbook' }
  end

  describe '#maintainer' do
    subject { cookbook.maintainer }
    it { is_expected.to eq 'MadGlory' }
  end

  describe '#path' do
    subject { cookbook.path }
    it { is_expected.to eq Pathname.new('spec/fixtures/sample_cookbook') }
  end

  describe '#web_friendly_version' do
    subject { cookbook.web_friendly_version }
    it { is_expected.to eq '1_2_3' }
  end

  describe '#dependencies' do
    subject { cookbook.dependencies }
    it { is_expected.to eq('yum' => '> 3.0.0') }
  end

  describe '#readme_file' do
    subject { cookbook.readme_file }
    it { is_expected.to eq 'spec/fixtures/sample_cookbook/README.md' }
  end

  describe '#changelog_file' do
    subject { cookbook.changelog_file }
    it { is_expected.to eq 'spec/fixtures/sample_cookbook/CHANGELOG.md' }
  end

  describe '#readme_content' do
    it 'should use the markdown parser to parse the readme content' do
      expect(Minimart::Web::MarkdownParser).to receive(:parse).with('spec/fixtures/sample_cookbook/README.md')
      cookbook.readme_content
    end
  end

  describe '#changelog_content' do
    it 'should use the markdown parser to parse the changelog content' do
      expect(Minimart::Web::MarkdownParser).to receive(:parse).with('spec/fixtures/sample_cookbook/CHANGELOG.md')
      cookbook.changelog_content
    end
  end

  describe '#to_json' do
    subject { JSON.parse(cookbook.to_json) }

    it do
      is_expected.to include(
        'name' => 'sample_cookbook',
        'version' => '1.2.3',
        'description' => 'Installs/Configures sample_cookbook',
        'maintainer' => 'MadGlory',
        'download_url' => 'cookbook_files/sample_cookbook/1_2_3/sample_cookbook-1.2.3.tar.gz',
        'url' => 'cookbooks/sample_cookbook/1.2.3.html')
    end
  end

  describe '#satisfies_requirement?' do
    context 'when the cookbook satisfies the requirement' do
      subject { cookbook.satisfies_requirement?('~> 1.2.0') }
      it { is_expected.to eq true }
    end

    context 'when the cookbook does not satisfy the requirement' do
      subject { cookbook.satisfies_requirement?('>= 2.0.0') }
      it { is_expected.to eq false }
    end
  end

  describe '#downloaded_at' do
    let(:path) { File.join(test_directory, 'sample_cookbook') }
    let(:cookbook) { Minimart::Cookbook.new(path) }
    let(:metadata) { Minimart::Mirror::DownloadMetadata.new(cookbook.path) }

    before(:each) do
      FileUtils.cp_r('spec/fixtures/sample_cookbook', path)
      metadata.write
    end

    subject { cookbook.downloaded_at }

    it { is_expected.to eq metadata.downloaded_at }
    it { is_expected.to be_a Time }
  end

  describe '#download_date' do
    let(:date) { Time.new(2001, 06, 01) }

    before(:each) do
      allow_any_instance_of(Minimart::Mirror::DownloadMetadata).to receive(:downloaded_at).and_return date
    end

    subject { cookbook.download_date }

    it { is_expected.to eq 'June 01, 2001' }
  end

end
