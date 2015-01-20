require 'spec_helper'

describe Minimart::Mirror::InventoryRequirements do

  let(:raw_requirements) do
    {
      'sample_cookbook' => {'path' => 'spec/fixtures/sample_cookbook'},
      'mysql' => {
        'versions' => ['~> 5.6.1'],
        'git'      => {
          'location' => 'https://github.com/opscode-cookbooks/mysql',
          'branches' => ['windows'],
          'refs'     => ['git-ref-sha'],
          'tags'     => ['v5.2.0']
        }
      }
    }
  end

  subject do
    Minimart::Mirror::InventoryRequirements.new(raw_requirements)
  end

  describe "::new" do
    it 'should build any cookbooks for any listed versions' do
      expect(subject.any? { |c| c.version_requirement == '~> 5.6.1' }).to eq true
    end

    it 'should build cookbooks for any git branches' do
      expect(subject.any? { |c| c.respond_to?(:branch) && c.branch == 'windows' }).to eq true
    end

    it 'should build cookbooks for any git tags' do
      expect(subject.any? { |c| c.respond_to?(:tag) && c.tag == 'v5.2.0' }).to eq true
    end

    it 'should build cookbooks for any git refs' do
      expect(subject.any? { |c| c.respond_to?(:ref) && c.ref == 'git-ref-sha' }).to eq true
    end

    it 'should build any cookbooks for local paths' do
      expect(subject.any? { |c| c.respond_to?(:path) && c.path == 'spec/fixtures/sample_cookbook' }).to eq true
    end

    context 'when no requirements can be found for a given cookbook' do
      before(:each) do
        raw_requirements['mysql'] = {'not-a-real-setting' => '~> 5.6.1'}
      end

      it 'should raise an error' do
        expect {
          subject
        }.to raise_error Minimart::Error::InvalidInventoryError,
          "Minimart could not find any requirements for 'mysql'"
      end
    end
  end

  describe '#version_required?' do
    context 'when the passed in cookbook was not specified in the local inventory' do
      it 'should return true' do
        expect(subject.version_required?('new-book', '0.0.1')).to eq true
      end
    end

    context 'when the passed in cookbook solves a requirement specified in the local inventory' do
      it 'should return true' do
        expect(subject.version_required?('mysql', '5.6.2')).to eq true
      end
    end

    context 'when the passed in cookbook does not solve an explicitly defined requirement in the inventory' do
      it 'should return false' do
        expect(subject.version_required?('mysql', '5.5.0')).to eq false
      end
    end
  end
end
