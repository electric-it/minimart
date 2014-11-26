require 'spec_helper'

describe Minimart::Source::SourceList do

  let(:url) { 'https://fakemarket.com' }

  describe '::build_source' do
    context 'when the type provided is "git"' do
      it 'should build a Source::Git' do
        new_source = Minimart::Source::SourceList.build_source(url, 'type' => 'git')
        expect(new_source).to be_a Minimart::Source::Git
      end
    end

    context 'when no type is provided' do
      it 'should default to Source::Supermarket' do
        new_source = Minimart::Source::SourceList.build_source(url, {})
        expect(new_source).to be_a Minimart::Source::Supermarket
      end
    end
  end

  subject { Minimart::Source::SourceList.new }

  let(:git_source) { Minimart::Source::Git.new(url, {}) }
  let(:supermarket_source) { Minimart::Source::Supermarket.new(url, {}) }

  before(:each) do
    subject.add git_source
    subject.add supermarket_source
  end

  describe '#with_location_specifications' do
    it 'should include a git source' do
      expect(subject.with_location_specifications).to include git_source
    end

    it 'should not include a supermarket source' do
      expect(subject.with_location_specifications).to_not include supermarket_source
    end
  end

  describe '#with_supermarket_specifications' do
    it 'should not include a git source' do
      expect(subject.with_supermarket_specifications).to_not include git_source
    end

    it 'should include a supermarket source' do
      expect(subject.with_supermarket_specifications).to include supermarket_source
    end
  end

end
