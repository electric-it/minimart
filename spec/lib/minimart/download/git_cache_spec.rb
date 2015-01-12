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

end
