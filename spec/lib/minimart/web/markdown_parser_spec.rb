require 'spec_helper'

describe Minimart::Web::MarkdownParser do

  before(:each) { activate_fake_fs }
  after(:each) { deactivate_fake_fs }

  describe '::parse' do
    context 'when the file does not have a markdown extension' do
      let(:contents) { 'file contents here' }

      let(:file) do
        '/readme.rdoc'.tap do |file_name|
          File.open(file_name, 'w+') { |f| f.write(contents) }
        end
      end

      it 'should return the file contents' do
        expect(Minimart::Web::MarkdownParser.parse(file)).to eq contents
      end

      it 'should not attempt to parse the file' do
        expect(Minimart::Web::MarkdownParser).to_not receive(:new)
        Minimart::Web::MarkdownParser.parse(file)
      end
    end

    context 'when the file has a .md extension' do
      let(:contents) { '# Title' }

      let(:file) do
        '/readme.md'.tap do |file_name|
          File.open(file_name, 'w+') { |f| f.write(contents) }
        end
      end

      it 'should parse the contents as markdown' do
        expect(Minimart::Web::MarkdownParser.parse(file)).to match '<h1>Title</h1>'
      end
    end

    context 'when the file has a .markdown extension' do
      let(:contents) { '# Title' }

      let(:file) do
        '/readme.markdown'.tap do |file_name|
          File.open(file_name, 'w+') { |f| f.write(contents) }
        end
      end

      it 'should parse the contents as markdown' do
        expect(Minimart::Web::MarkdownParser.parse(file)).to match '<h1>Title</h1>'
      end
    end
  end

end
