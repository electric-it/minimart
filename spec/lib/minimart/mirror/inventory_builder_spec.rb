require 'spec_helper'

describe Minimart::Mirror::InventoryBuilder do

  subject do
    Minimart::Mirror::InventoryBuilder.new(test_directory, inventory_config)
  end

  describe '#build' do
    describe 'when a git cookbook is present' do
      let(:inventory_config) do
        Minimart::Mirror::InventoryConfiguration.new('spec/fixtures/simple_git_inventory.yml')
      end

      before(:each) do
        # stub out actually cloning the repo
        allow_any_instance_of(Minimart::Download::GitRepository).to receive(:fetch).and_yield 'spec/fixtures/sample_cookbook'
      end

      around(:each) do |e|
        VCR.use_cassette('location_specific_cookbooks') { e.call }
      end

      it 'should add the cookbook to the graph' do
        subject.build!
        expect(subject.graph.source_cookbook_added?('sample_cookbook', '1.2.3')).to eq true
      end

      it 'should add the cookbook to the local store' do
        subject.build!
        expect(subject.local_store.installed?('sample_cookbook', '1.2.3')).to eq true
      end

      it 'should add any dependencies of the cookbook to the local store' do
        subject.build!
        expect(subject.local_store.installed?('yum', '3.5.1')).to eq true
      end

      it 'should clear the git cache' do
        expect_any_instance_of(Minimart::Download::GitCache).to receive :clear
        subject.build!
      end

      it 'should store metadata about downloading the cookbook' do
        subject.build!
        metadata = JSON.parse(File.open(File.join(test_directory, 'sample_cookbook-1.2.3', '.minimart.json')).read)
        expect(metadata).to include(
          'source_type'    => 'git',
          'location'       => 'spec/fixtures/sample_cookbook',
          'commitish_type' => 'tag',
          'commitish'      => 'v1.2.3')
      end
    end

    describe 'when a cookbook with a local path is present' do
      let(:inventory_config) do
        Minimart::Mirror::InventoryConfiguration.new('spec/fixtures/simple_local_path_inventory.yml')
      end

      around(:each) do |e|
        VCR.use_cassette('local_path_cookbooks') { e.call }
      end

      it 'should add the cookbook to the graph' do
        subject.build!
        expect(subject.graph.source_cookbook_added?('sample_cookbook', '1.2.3')).to eq true
      end

      it 'should add the cookbook to the local store' do
        subject.build!
        expect(subject.local_store.installed?('sample_cookbook', '1.2.3')).to eq true
      end

      it 'should add any dependencies of the cookbook to the local store' do
        subject.build!
        expect(subject.local_store.installed?('yum', '3.5.1')).to eq true
      end

      it 'should store metadata about downloading the cookbook' do
        subject.build!
        metadata = JSON.parse(File.open(File.join(test_directory, 'sample_cookbook-1.2.3', '.minimart.json')).read)
        expect(metadata).to include('source_type' => 'local_path')
      end
    end

    describe 'fetching cookbooks from a supermarket' do
      let(:inventory_config) do
        Minimart::Mirror::InventoryConfiguration.new('spec/fixtures/simple_inventory.yml')
      end

      describe 'building the dependency graph' do
        before(:each) do
          stub_request(:get, "https://supermarket.getchef.com/universe").
            to_return(status: 200, body: File.open('spec/fixtures/universe.json').read)
        end

        around(:each) do |e|
          VCR.use_cassette('supermarket_cookbooks_graph') { e.call }
        end

        let(:expected_universe) do
          [['mysql', '5.6.1'], ['mysql', '5.5.4'], ['yum', '3.4.1', '3.3.1']]
        end

        it 'should populate the dependency graph with anything returned by the universe' do
          subject.build!
          expected_universe.each do |name, version|
            expect(subject.graph.source_cookbook_added?(name, version)).to eq true
          end
        end
      end

      describe 'installing cookbooks' do
        around(:each) do |e|
          VCR.use_cassette('supermarket_cookbooks_installing_cookbooks') { e.call }
        end

        it 'should add the resolved version of the cookbook to the local store' do
          subject.build!
          expect(subject.local_store.installed?('mysql', '5.5.4')).to eq true
        end

        it 'should add the cookbook to the local inventory' do
          subject.build!
          expect(Dir.exists?(File.join(test_directory, 'mysql-5.5.4'))).to eq true
        end

        it 'should add any resolved dependencies to the local store' do
          subject.build!
          expect(subject.local_store.installed?('yum', '3.5.1')).to eq true
          expect(subject.local_store.installed?('yum-mysql-community', '0.1.10')).to eq true
        end

        it 'should actually add the dependent cookbooks to the local inventory' do
          subject.build!
          expect(Dir.exists?(File.join(test_directory, 'yum-3.5.1'))).to eq true
          expect(Dir.exists?(File.join(test_directory, 'yum-mysql-community-0.1.10'))).to eq true
        end

        it 'should store metadata about downloading the cookbook' do
          subject.build!
          metadata = JSON.parse(File.open(File.join(test_directory, 'mysql-5.5.4', '.minimart.json')).read)
          expect(metadata).to include(
            'source_type'    => 'opscode',
            'location'       => 'https://supermarket.chef.io/api/v1')
        end

        context 'when a cookbook has already been installed' do
          before(:each) do
            allow(subject.local_store).to receive(:installed?).and_return true
          end

          it 'should not download the cookbooks a second time' do
            expect(Minimart::Download::Cookbook).to_not receive(:download)
            subject.build!
          end
        end

        context 'when a coookbook depends on a non explicit version of a required cookbook' do
          let(:bad_requirements) do
            [%w[mysql 5.4], %w[mysql 0.0.1]]
          end

          before(:each) do
            allow_any_instance_of(Minimart::Mirror::DependencyGraph).to receive(:resolved_requirements).and_return(bad_requirements)
          end

          it 'should raise an error' do
            expect {
              subject.build!
            }.to raise_error Minimart::Error::BrokenDependency
          end
        end
      end

    end
  end
end
