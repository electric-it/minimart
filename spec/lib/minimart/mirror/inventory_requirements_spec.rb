require 'spec_helper'

describe Minimart::Mirror::InventoryRequirements do

  let(:raw_requirements) do
    {
      'sample_cookbook' => {'path' => 'spec/fixtures/sample_cookbook'},
      'mysql' => {
        'versions' => ['~> 5.6.1'],
        'git'      => {
          'url'      => 'https://github.com/opscode-cookbooks/mysql',
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
  end
end
