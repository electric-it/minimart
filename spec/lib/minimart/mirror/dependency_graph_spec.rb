require 'spec_helper'

describe Minimart::Mirror::DependencyGraph do

  subject do
    Minimart::Mirror::DependencyGraph.new
  end

  let(:cookbook) do
    Minimart::Mirror::SourceCookbook.new(
      name: 'mysql',
      version: '1.0.0',
      dependencies: { 'yum' => '> 1.0.0' })
  end

  describe '#add_artifact' do

    before(:each) do
      subject.add_artifact(cookbook)
    end

    it 'should add the cookbook to the graph' do
      expect(subject.source_cookbook_added?(cookbook.name, cookbook.version)).to eq true
    end

    it 'should not have any dependencies' do
      expect(subject.find_graph_artifact(cookbook).dependencies).to eq []
    end

    it 'should not add any possible dependencies to the graph' do
      expect(subject.find_graph_artifact(cookbook).dependencies.map(&:name)).to_not include 'yum'
    end

    context 'when the cookbook has already been added' do
      let(:modified_cookbook) do
        Minimart::Mirror::SourceCookbook.new(
          name: 'mysql',
          version: '1.0.0',
          dependencies: { 'apt' => '> 1.0.0' })
      end

      before(:each) do
        subject.add_artifact(modified_cookbook)
      end

      it 'should not add any new dependencies' do
        expect(subject.find_graph_artifact(cookbook).dependencies.map(&:name)).to_not include 'apt'
      end

    end
  end

  describe '#source_cookbook_added?' do
    context 'when the cookbook has been added' do
      before(:each) { subject.add_artifact(cookbook) }

      it 'should return true' do
        expect(subject.source_cookbook_added?(cookbook.name, cookbook.version)).to eq true
      end
    end

    context 'when the cookbook has not been added' do
      it 'should return false' do
        expect(subject.source_cookbook_added?(cookbook.name, cookbook.version)).to eq false
      end
    end
  end

  describe '#add_requirement' do
    it 'should add the requirement' do
      subject.add_requirement('yum' => '~> 1.0.0')
      expect(subject.inventory_requirements).to include ['yum', '~> 1.0.0']
    end
  end

  describe '#resolved_requirements' do
    let(:apt_cookbook) do
      Minimart::Mirror::SourceCookbook.new(name: 'apt', version: '2.0.0')
    end

    let(:yum_cookbook) do
      Minimart::Mirror::SourceCookbook.new(name: 'yum', version: '5.0.0')
    end

    context 'when all dependencies are met' do
      before(:each) do
        subject.add_artifact(cookbook)
        subject.add_artifact(yum_cookbook)
        subject.add_artifact(apt_cookbook)
        subject.add_requirement('apt' => '> 1.0.0')
        subject.add_requirement('mysql' => '= 1.0.0')
      end

      it 'should return a resolved mysql version' do
        expect(subject.resolved_requirements).to include ['mysql', '1.0.0']
      end

      it 'should return a resolved apt version' do
        expect(subject.resolved_requirements).to include ['apt', '2.0.0']
      end

      it 'should not return a resolved yum version for the mysql dependency' do
        expect(subject.resolved_requirements).to_not include ['yum', '5.0.0']
      end
    end

    context 'when a dependency cannot be resolved' do
      before(:each) do
        # leaving out the yum dependency needed for mysql
        subject.add_artifact(cookbook)
        subject.add_requirement('mysql' => '= 1.0.0')
      end

      it 'should not raise an error' do
        expect {
          subject.resolved_requirements
        }.to_not raise_error Minimart::Error::UnresolvedDependency
      end
    end
  end
end
