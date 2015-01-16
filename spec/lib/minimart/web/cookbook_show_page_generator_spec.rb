require 'spec_helper'
require 'minimart/web/cookbook_show_page_generator'

describe Minimart::Web::CookbookShowPageGenerator do
  let(:cookbooks) do
    Minimart::Web::Cookbooks.new(inventory_directory: 'spec/fixtures')
  end

  let(:web_directory) { test_directory }

  subject do
    Minimart::Web::CookbookShowPageGenerator.new(
    web_directory: web_directory,
    cookbooks:     cookbooks)
  end

  describe '#generate' do
    let(:cookbook_directory) { File.join(web_directory, 'cookbooks', 'sample_cookbook') }
    let(:cookbook_file) { File.join(cookbook_directory, '1.2.3.html') }
    let(:view_content) { File.open(cookbook_file).read }

    it 'should generate a directory for the cookbook provided' do
      subject.generate
      expect(Dir.exists?(cookbook_directory)).to eq true
    end

    it 'should generate an html file for the cookbook version' do
      subject.generate
      expect(File.exists?(cookbook_file)).to eq true
    end

    it 'should have a proper link back to the home page' do
      subject.generate
      expect(view_content).to match(%{href="../../index.html"})
    end

    it 'should have a form for the search action with the proper path' do
      subject.generate
      expect(view_content).to match(%{action="../../index.html#search/"})
    end

    it 'should have the proper relative path to any loaded assets' do
      subject.generate
      expect(view_content).to match %{href="../../assets/}
    end

    it 'should display the name of the cookbook' do
      subject.generate
      expect(view_content).to match 'sample_cookbook'
    end

    it 'should display the version of the cookbook' do
      subject.generate
      expect(view_content).to match '1.2.3'
    end

    it 'should display a link to download the cookbook' do
      subject.generate
      expect(view_content).to match %{href="../../cookbook_files/sample_cookbook/1_2_3/sample_cookbook-1.2.3.tar.gz"}
    end

    it 'should display any dependencies the cookbook has' do
      subject.generate
      expect(view_content).to match 'yum > 3.0.0'
    end
  end

end
