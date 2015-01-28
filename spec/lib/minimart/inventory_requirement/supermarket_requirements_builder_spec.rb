require 'spec_helper'

describe Minimart::InventoryRequirement::SupermarketRequirementsBuilder do

  let(:versions) { ['> 1.0.0', '~> 0.1'] }

  subject do
    described_class.new('mysql', 'versions' => versions)
  end

  describe '#build' do
    it 'should return an array' do
      expect(subject.build).to be_a Array
    end

    it 'should build requirements using the base requirement class' do
      expect(subject.build.first).to be_a Minimart::InventoryRequirement::BaseRequirement
    end

    it "should build a requirement for version '> 1.0.0'" do
      requirements = subject.build
      expect(requirements.any? { |r| r.version_requirement == '> 1.0.0'}).to eq true
    end

    it "should build a requirement for version '~> 0.1'" do
      requirements = subject.build
      expect(requirements.any? { |r| r.version_requirement == '~> 0.1'}).to eq true
    end

    context 'when no versions are supplied' do
      subject do
        described_class.new('mysql', {})
      end

      it 'should return an empty array' do
        expect(subject.build).to be_empty
      end
    end

    context 'when a string version is supplied' do
      subject do
        described_class.new('mysql', 'versions' => '~> 0.1')
      end

      it 'should build a single requirement' do
        expect(subject.build.size).to eq 1
      end

      it 'should give the requirement the proper version' do
        expect(subject.build.first.version_requirement).to eq '~> 0.1'
      end

      it 'should give the requirement the proper name' do
        expect(subject.build.first.name).to eq 'mysql'
      end
    end

    context 'when the string "version" is used as the key' do
      subject do
        described_class.new('mysql', 'version' => '~> 0.1')
      end

      it 'should give the requirement the proper version' do
        expect(subject.build.first.version_requirement).to eq '~> 0.1'
      end
    end
  end

end
