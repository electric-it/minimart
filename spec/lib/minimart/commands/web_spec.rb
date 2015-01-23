require 'spec_helper'
require 'minimart/commands/web'

describe Minimart::Commands::Web do

  let(:inventory_directory)  { File.join(test_directory, 'my-inventory') }
  let(:web_directory) { File.join(test_directory, 'my-site') }
  let(:endpoint) { 'http://example.com' }

  subject do
    Minimart::Commands::Web.new(
      inventory_directory: inventory_directory,
      web_directory:       web_directory,
      host:                endpoint)
  end

  describe '::new' do
    it 'should set the inventory directory' do
      expect(subject.inventory_directory).to eq File.expand_path(inventory_directory)
    end

    it 'should set the web directory' do
      expect(subject.web_directory).to eq File.expand_path(web_directory)
    end

    it 'should set the web endpoint' do
      expect(subject.web_endpoint).to eq endpoint
    end
  end

  describe '#execute!' do
    let(:generator_double) { double('generator', generate: true) }

    before(:each) do
      allow_any_instance_of(Minimart::Web::UniverseGenerator).to receive(:generate)
      allow_any_instance_of(Minimart::Web::HtmlGenerator).to receive(:generate)
    end

    it 'should make the web directory' do
      subject.execute!
    end

    it 'should generate the universe.json file' do
      expect(Minimart::Web::UniverseGenerator).to receive(:new).with(
        web_directory: subject.web_directory,
        endpoint: subject.web_endpoint,
        cookbooks: an_instance_of(Minimart::Web::Cookbooks)).and_return generator_double

      subject.execute!
    end

    it 'should generate the static HTML files' do
      expect(Minimart::Web::HtmlGenerator).to receive(:new).with(
        web_directory: subject.web_directory,
        cookbooks: an_instance_of(Minimart::Web::Cookbooks)).and_return generator_double

      subject.execute!
    end

    context 'when the user disable html generation' do
      subject do
        Minimart::Commands::Web.new(
          html:                false,
          inventory_directory: inventory_directory,
          web_directory:       web_directory,
          web_endpoint:            endpoint)
      end

      it 'should not execute the html generator' do
        expect(Minimart::Web::HtmlGenerator).to_not receive(:new)
        subject.execute!
      end
    end
  end
end
