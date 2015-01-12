require 'spec_helper'

describe Minimart::Mirror::GitRequirementsBuilder do

  let(:raw_requirements) do
    {
      'git' => {
        'location' => 'https://github.com/mysql',
        'branches' => %w[branch-one branch-two],
        'tags' => %w[tag-one tag-two],
        'refs' => %w[ref-one ref-two],
      }
    }
  end

  subject do
    Minimart::Mirror::GitRequirementsBuilder.new('mysql', raw_requirements)
  end

  describe '#build' do
    it 'should build a requirement for each branch' do
      raw_requirements['git']['branches'].each do |branch|
        expect(subject.build.any? { |r| r.branch == branch }).to eq true
      end
    end

    it 'should build a requirement for each tag' do
      raw_requirements['git']['tags'].each do |tag|
        expect(subject.build.any? { |r| r.tag == tag }).to eq true
      end
    end

    it 'should build a requirement for each ref' do
      raw_requirements['git']['refs'].each do |ref|
        expect(subject.build.any? { |r| r.ref == ref }).to eq true
      end
    end

    it 'should pass the location' do
      expect(subject.build.all? { |r| r.location == 'https://github.com/mysql' }).to eq true
    end

    context 'when branches is passed a string' do
      before(:each) { raw_requirements['git'] = { 'branches' => 'master' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.branch).to eq 'master'
      end
    end

    context 'when tags is passed a string' do
      before(:each) { raw_requirements['git'] = { 'tags' => 'v0.0.0' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.tag).to eq 'v0.0.0'
      end
    end

    context 'when refs is passed a string' do
      before(:each) { raw_requirements['git'] = { 'refs' => 'SHA' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.ref).to eq 'SHA'
      end
    end

    context 'when there are no git requirements' do
      subject do
        Minimart::Mirror::GitRequirementsBuilder.new('mysql', {})
      end

      it 'should return an empty array' do
        expect(subject.build.empty?).to eq true
      end
    end
  end

end
