require 'spec_helper'

describe Minimart::InventoryCookbook::GitCookbook do

  subject do
    Minimart::InventoryCookbook::GitCookbook.new(
      'mysql',
      branch: 'new-feature-branch')
  end

  describe '::new' do
    it 'should set the name' do
      expect(subject.name).to eq 'mysql'
    end

    context 'when a branch is provided' do
      it 'should set the branch' do
        expect(subject.branch).to eq 'new-feature-branch'
      end
    end

    context 'when a ref is provided' do
      it 'should set the sha' do
        cookbook = Minimart::InventoryCookbook::GitCookbook.new('mysql', ref: 'SHA')
        expect(cookbook.ref).to eq 'SHA'
      end
    end

    context 'when a tag is provided' do
      it 'should set the tag' do
        cookbook = Minimart::InventoryCookbook::GitCookbook.new('mysql', tag: 'v1.0.0')
        expect(cookbook.tag).to eq 'v1.0.0'
      end
    end
  end

  describe '#location_specification?' do
    it 'should return true' do
      expect(subject.location_specification?).to eq true
    end
  end
end
