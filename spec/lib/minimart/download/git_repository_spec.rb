require 'spec_helper'

describe Minimart::Download::GitRepository do

  let(:location) { 'http://github.com' }

  subject do
    Minimart::Download::GitRepository.new(location)
  end

  describe '#fetch' do
    let(:repo) do
      instance_double('Git::Base',
        fetch:      true,
        reset_hard: true,
        revparse:   'master')
    end

    let(:path) { '/git_path' }

    before(:each) do
      allow_any_instance_of(Minimart::Download::GitCache).to receive(:get_repository).with(location).and_return repo
      allow_any_instance_of(Minimart::Download::GitCache).to receive(:local_path_for).with(location).and_return path
      allow(Git).to receive(:clone).with(path, an_instance_of(String)).and_return repo
    end

    it 'should clone the repo' do
      expect(repo).to receive(:reset_hard).with('master')
      subject.fetch('master')
    end

    it 'should yield the directory the repo was cloned to' do
      expect { |b|
        subject.fetch('master', &b)
      }.to yield_with_args(an_instance_of(String))
    end
  end

end
