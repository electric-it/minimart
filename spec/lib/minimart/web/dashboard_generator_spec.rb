require 'spec_helper'
require 'minimart/web/dashboard_generator'

describe Minimart::Web::DashboardGenerator do
  let(:cookbooks) do
    Minimart::Web::Cookbooks.new(inventory_directory: 'spec/fixtures')
  end

  let(:web_directory) { test_directory }

  subject do
    Minimart::Web::DashboardGenerator.new(
      web_directory: web_directory,
      cookbooks:     cookbooks)
  end

  describe '#generate' do
    it 'should create an index.html file in the web directory' do
      subject.generate
      expect(File.exists?(File.join(web_directory, 'index.html'))).to eq true
    end

    it 'should have a proper link back to the home page' do
      subject.generate
      expect(subject.template_content).to match(%{href="index.html"})
    end

    it 'should have the proper relative path to any loaded assets' do
      subject.generate
      expect(subject.template_content).to match %{href="assets/}
    end
  end
end
