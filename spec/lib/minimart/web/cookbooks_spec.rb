require 'spec_helper'
require 'minimart/web/cookbooks'

describe Minimart::Web::Cookbooks do

  let(:inventory_directory) { 'spec/fixtures/' }
  let(:data_path) { File.join(directory, 'data.json') }

  subject do
    Minimart::Web::Cookbooks.new(inventory_directory: inventory_directory)
  end

  describe '::new' do
    it 'should set the #inventory_directory' do
      expect(subject.inventory_directory).to eq inventory_directory
    end

    it 'should build a data structure with the proper cookbooks' do
      expect(subject.keys).to include 'sample_cookbook'
    end

    it 'should load the cookbooks provided' do
      expect(subject['sample_cookbook'].first).to be_a Minimart::Cookbook
    end

    context 'when there are multiple versions of the same cookbook' do
      let(:cookbook_one) { instance_double(Minimart::Cookbook, name: 'test-book', version: '1.9.0') }
      let(:cookbook_two) { instance_double(Minimart::Cookbook, name: 'test-book', version: '1.19.0') }
      let(:cookbooks) { [cookbook_one, cookbook_two] }

      before(:each) do
        allow_any_instance_of(Minimart::Web::Cookbooks).to receive(:cookbooks).and_return cookbooks
      end

      it 'should load both cookbooks' do
        expect(subject['test-book'].size).to eq 2
      end

      it 'should properly sort them in version descending order' do
        expect(subject['test-book'][0].version).to eq '1.19.0'
        expect(subject['test-book'][1].version).to eq '1.9.0'
      end
    end
  end

  describe '::to_json' do
    let(:result) { JSON.parse(subject.to_json) }

    it 'should return the proper data structure as JSON' do
      expect(result.first['name']).to eq 'sample_cookbook'
    end

    it 'should include the number of versions available' do
      expect(result.first['available_versions']).to eq 1
    end
  end

end
