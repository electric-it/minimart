require 'spec_helper'

describe Minimart::InventoryCookbook::BaseCookbook do

  subject do
    Minimart::InventoryCookbook::BaseCookbook.new(
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
end
