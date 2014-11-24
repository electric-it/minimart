require 'spec_helper'

describe Minimart::Mirror::Universe do

  let(:base_url) { 'https://fakesupermarket.com/chef' }

  subject { Minimart::Mirror::Universe.new(base_url) }

  let(:raw_universe) { File.open('spec/fixtures/universe.json').read }

  before(:each) do
    stub_request(:get, "#{base_url}/universe").
      to_return(status: 200, body: raw_universe)
  end

  describe '#find_cookbook' do
    describe 'when a cookbook is present in the universe' do
      it 'should return a matching cookbook' do
        result = subject.find_cookbook('mysql', '5.6.1')
        expect(result.name).to eq 'mysql'
        expect(result.version).to eq '5.6.1'
      end
    end

    describe 'when a cookbook is not present in the universe' do
      it 'should return nil' do
        expect(subject.find_cookbook('madeup', '0.0.1')).to be_nil
      end
    end

    context 'when the given universe does not exist' do
      before(:each) do
        stub_request(:get, "#{base_url}/universe").to_return(status: 404)
      end

      it 'should raise the proper exception' do
        expect {
          subject.find_cookbook('mysql', '5.6.1')
        }.to raise_error(
          Minimart::Mirror::UniverseNotFoundError,
          "no universe found for #{base_url}")
      end
    end
  end

  describe '#find_cookbook_for_requirements' do
    it 'should return the matching cookbook' do
      result = subject.find_cookbook_for_requirements('yum', '> 0.0')
      expect(result.name).to eq 'yum'
      expect(result.version).to eq '3.4.1'
    end

    context 'when the requirements can not be met' do
      it 'should raise an exception' do
        expect {
          subject.find_cookbook_for_requirements('yum', '> 100.0')
        }.to raise_error(Minimart::Mirror::DependencyNotMet,
          "could not fulfill dependency yum with requirements `> 100.0`")
      end
    end
  end

  describe '#resolve_dependency' do
    it 'should return the best resolution for the dependency' do
      expect(subject.resolve_dependency('yum', '>= 0.0.0')).to eq '3.4.1'
    end

    context 'when no cookbook can be found for the given dependency' do
      it 'should return nil' do
        expect(subject.resolve_dependency('not_in_universe', '>= 0.0.0')).to be_nil
      end
    end

    context 'when the universe does not exist' do
      before(:each) do
        stub_request(:get, "#{base_url}/universe").to_return(status: 404)
      end

      it 'should raise the proper exception' do
        expect {
          subject.resolve_dependency('yum', '>= 0.0.0')
        }.to raise_error(
          Minimart::Mirror::UniverseNotFoundError,
          "no universe found for #{base_url}")
      end
    end
  end

end
