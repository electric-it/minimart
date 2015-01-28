require 'spec_helper'

describe Minimart::Download::GitCache do

  describe '#get_repository' do
    let(:stubbed_repo) { double('git_repository') }

    before(:each) do
      allow(Git).to receive(:clone).and_return(stubbed_repo)
    end

    it 'should return the repo' do
      expect(subject.get_repository('git-url')).to eq stubbed_repo
    end

    it 'should download a bare version of the git repo' do
      expect(Git).to receive(:clone).with('git-url', instance_of(String), bare: true)
      subject.get_repository('git-url')
    end

    context 'when the repo has already been downloaded' do
      before(:each) do
        subject.get_repository('git-url')
      end

      it 'should return the repo' do
        expect(subject.get_repository('git-url')).to eq stubbed_repo
      end

      it 'should not download the repo a second time' do
        expect(Git).to_not receive(:clone)
        subject.get_repository('git-url')
      end
    end
  end

  describe '#local_path_for' do
    let(:stubbed_repo) { double('git_repository', repo: double('repo', path: '/path')) }

    before(:each) do
      allow(subject).to receive(:get_repository).and_return stubbed_repo
    end

    it 'should return the path' do
      expect(subject.local_path_for('repo')).to eq '/path'
    end
  end

  describe '#clear' do
    let(:path) { Dir.mktmpdir }
    let(:repo) { double('base', repo: double('repo', 'path' => path)) }

    before(:each) do
      allow(Git).to receive(:clone).and_return(repo)
      subject.get_repository('git-url')
    end

    it 'should remove empty the cache' do
      subject.clear
      expect(subject.has_location?('git-url')).to eq false
    end

    it 'should actually remove any tmp directories' do
      subject.clear
      expect(Dir.exists?(path)).to eq false
    end
  end

end
