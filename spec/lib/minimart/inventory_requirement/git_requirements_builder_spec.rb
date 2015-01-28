require 'spec_helper'

describe Minimart::InventoryRequirement::GitRequirementsBuilder do

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
    Minimart::InventoryRequirement::GitRequirementsBuilder.new('mysql', raw_requirements)
  end

  describe '::new' do
    context 'when a location is not provided' do
      before(:each) { raw_requirements['git'].delete('location') }

      it 'should raise an exception' do
        expect {
          subject
        }.to raise_error Minimart::Error::InvalidInventoryError,
          %{'mysql' specifies Git requirements, but does not have a location.}
      end
    end

    context 'when no commitish is specified' do
      let(:raw_requirements) do
        { 'git' => {'location' => '/'} }
      end

      it 'should raise an exception' do
        expect {
          subject
        }.to raise_error Minimart::Error::InvalidInventoryError,
          %{'mysql' specified Git requirements, but does not provide a branch|tag|ref}
      end
    end
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
      before(:each) { raw_requirements['git'] = { 'location' => '/', 'branches' => 'master' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.branch).to eq 'master'
      end
    end

    context 'when the string "branch" is used as the key' do
      before(:each) { raw_requirements['git'] = { 'location' => '/', 'branch' => 'master' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.branch).to eq 'master'
      end
    end

    context 'when tags is passed a string' do
      before(:each) do
        raw_requirements['git'] = { 'location' => '/', 'tags' => 'v0.0.0' }
      end

      it 'should still build the proper requirement' do
        expect(subject.build.first.tag).to eq 'v0.0.0'
      end
    end

    context 'when the string "tag" is used as the key' do
      before(:each) { raw_requirements['git'] = { 'location' => '/', 'tag' => 'v0.0.0' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.tag).to eq 'v0.0.0'
      end
    end

    context 'when refs is passed a string' do
      before(:each) { raw_requirements['git'] = { 'location' => '/', 'refs' => 'SHA' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.ref).to eq 'SHA'
      end
    end

    context 'when the string "ref" is used as the key' do
      before(:each) { raw_requirements['git'] = { 'location' => '/', 'ref' => 'SHA' } }

      it 'should still build the proper requirement' do
        expect(subject.build.first.ref).to eq 'SHA'
      end
    end

    context 'when there are no git requirements' do
      subject do
        Minimart::InventoryRequirement::GitRequirementsBuilder.new('mysql', {})
      end

      it 'should return an empty array' do
        expect(subject.build.empty?).to eq true
      end
    end
  end

end
