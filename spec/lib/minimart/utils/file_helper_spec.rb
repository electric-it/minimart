require 'spec_helper'

describe Minimart::Utils::FileHelper do

  subject { Minimart::Utils::FileHelper }

  let(:cookbook_path) { 'spec/fixtures/sample_cookbook/' }

  describe '::cookbook_path_in_directory' do
    describe 'when the path passed is a cookbook' do
      it 'should return the path to the cookbook' do
        expect(subject.cookbook_path_in_directory(cookbook_path)).to eq cookbook_path
      end
    end

    describe 'when a cookbook is found one level deep in the directory structure' do
      it 'should return the path to the cookbook' do
        expect(subject.cookbook_path_in_directory('spec/fixtures')).to eq cookbook_path
      end
    end

    describe 'when no cookbook is found' do
      it 'should return nil' do
        expect(subject.cookbook_path_in_directory('spec/')).to eq nil
      end
    end
  end

  describe '::cookbook_in_path?' do
    describe 'when the path passed is a cookbook' do
      it 'should return true' do
        expect(subject.cookbook_in_path?('spec/fixtures/sample_cookbook')).to eq true
      end
    end

    describe 'when the path passed is not a cookbook' do
      it 'should return false' do
        expect(subject.cookbook_in_path?('spec/')).to eq false
      end
    end
  end

end
