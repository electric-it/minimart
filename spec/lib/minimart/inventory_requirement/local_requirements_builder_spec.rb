require 'spec_helper'

describe Minimart::InventoryRequirement::LocalRequirementsBuilder do

  describe '#build' do
    subject do
      Minimart::InventoryRequirement::LocalRequirementsBuilder.new('mysql', 'path' => '/my/local/path')
    end

    it 'should return a single requirement' do
      expect(subject.build.size).to eq 1
    end

    it 'should give the requirement the proper name' do
      expect(subject.build.first.name).to eq 'mysql'
    end

    it 'should give the requirement the proper path' do
      expect(subject.build.first.path).to eq '/my/local/path'
    end

    context 'when no path is provided' do
      subject do
        Minimart::InventoryRequirement::LocalRequirementsBuilder.new('mysql', {})
      end

      it 'should return empty' do
        expect(subject.build).to be_empty
      end
    end
  end

end
