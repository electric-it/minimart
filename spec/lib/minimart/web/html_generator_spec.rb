require 'spec_helper'
require 'minimart/web/html_generator'

describe Minimart::Web::HtmlGenerator do
  let(:cookbooks) do
    Minimart::Web::Cookbooks.new(inventory_directory: 'spec/fixtures')
  end

  let(:web_directory) { test_directory }
  let(:assets_directory) { File.join(web_directory, 'assets') }
  let(:stylesheets_directory) { File.join(assets_directory, 'stylesheets') }
  let(:javascripts_directory) { File.join(assets_directory, 'javascripts') }

  subject do
    Minimart::Web::HtmlGenerator.new(
      web_directory: web_directory,
      cookbooks:     cookbooks)
  end

  describe '#generate' do
    it 'should copy any available assets' do
      subject.generate
      expect(Dir.exist?(assets_directory)).to eq true
    end

    it 'should minify raw CSS files' do
      subject.generate
      expect(Dir.entries(stylesheets_directory)).to include('application.min.css')
    end

    it 'should unglify raw JS files' do
      subject.generate
      expect(Dir.entries(javascripts_directory)).to include('application.min.js')
    end

    it 'should generate the dashboard page' do
      expect_any_instance_of(Minimart::Web::DashboardGenerator).to receive(:generate)
      subject.generate
    end

    it 'should generate show pages for any of the cookbooks' do
      expect_any_instance_of(Minimart::Web::CookbookShowPageGenerator).to receive(:generate)
      subject.generate
    end
  end
end
