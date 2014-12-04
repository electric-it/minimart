require 'spec_helper'

describe Minimart::InventoryRequirement::BaseRequirement do

  subject do
    Minimart::InventoryRequirement::BaseRequirement.new(
      'mysql',
      version_requirement: '> 1.0.0')
  end

  describe '::new' do
    it 'should set the name' do
      expect(subject.name).to eq 'mysql'
    end

    it 'should set the version requirement' do
      expect(subject.version_requirement).to eq '> 1.0.0'
    end
  end

  describe '#location_specification?' do
    it 'should return false' do
      expect(subject.location_specification?).to eq false
    end
  end

  describe '#requirements' do
    it 'should return the proper requirements' do
      expect(subject.requirements).to eq 'mysql' => '> 1.0.0'
    end
  end
end
