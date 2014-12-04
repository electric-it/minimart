require 'spec_helper'

describe Minimart::InventoryRequirement::LocalPathRequirement do

  subject do
    Minimart::InventoryRequirement::LocalPathRequirement.new('sample_cookbook',
      path: 'spec/fixtures/sample_cookbook')
  end

  describe '::new' do
    it 'should set the name' do
      expect(subject.name).to eq 'sample_cookbook'
    end

    it 'should set the path' do
      expect(subject.path).to eq 'spec/fixtures/sample_cookbook'
    end
  end

  describe '#location_specification?' do
    it 'should return true' do
      expect(subject.location_specification?).to eq true
    end
  end
end
