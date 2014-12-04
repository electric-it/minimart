require 'spec_helper'

describe Minimart::Mirror::Sources do

  describe '::new' do
    let(:source_1) { 'https://supermarket.getchef.com' }
    let(:source_2) { 'https://supermarket.internal.com' }

    subject do
      Minimart::Mirror::Sources.new([source_1, source_2])
    end

    it 'should build a source with the first url provided' do
      expect(subject.map &:base_url ).to include source_1
    end

    it 'should build a source with the second url provided' do
      expect(subject.map &:base_url ).to include source_2
    end
  end

  describe '#find_cookbook' do
    subject do
      Minimart::Mirror::Sources.new(['https://supermarket.internal.com'])
    end

    let(:cookbook) { double('cookbook', name: 'mysql', version: '1.0.0') }

    before(:each) do
      allow_any_instance_of(Minimart::Mirror::Source).to receive(:cookbooks).and_return [cookbook]
    end

    context 'when a source has the given cookbook' do
      it 'should return the cookbook' do
        expect(subject.find_cookbook('mysql', '1.0.0')).to eq cookbook
      end
    end

    context 'when the cookbook cannot be found' do
      it 'should raise the proper exception' do
        expect {
          subject.find_cookbook('mysql', '2.0.0')
        }.to raise_error(
          Minimart::Error::CookbookNotFound,
          "The cookbook mysql with the version 2.0.0 could not be found")
      end
    end
  end

end
