require 'spec_helper'
require 'minimart/cli'

describe Minimart::Cli do

  before(:each) do
    @pwd = Dir.pwd
    Dir.chdir(test_directory)
  end

  after(:each) { Dir.chdir(@pwd) }

  describe '#init' do
    context 'when a config file option is provided' do
      it 'should create the file' do
        Minimart::Cli.start %w[init --inventory_config=./test-file.yml]
        expect(File.exists?('./test-file.yml')).to eq true
      end
    end

    it 'should create the default inventory file' do
      Minimart::Cli.start %w[init]
      expect(File.exists?('./inventory.yml')).to eq true
    end
  end

  describe '#mirror' do
    let(:command_double) { instance_double(Minimart::Commands::Mirror, execute!: true) }

    it 'should call the mirroring command with the proper options' do
      expect(Minimart::Commands::Mirror).to receive(:new).with(
        'inventory_config'    => './inventory.yml',
        'inventory_directory' => './inventory').and_return command_double

      Minimart::Cli.start %w[mirror]
    end

    it 'should allow users to override the default settings' do
      expect(Minimart::Commands::Mirror).to receive(:new).with(
        'inventory_config'    => './my-test.yml',
        'inventory_directory' => './test-dir').and_return command_double

      Minimart::Cli.start %w[mirror --inventory_config=./my-test.yml --inventory_directory=./test-dir]
    end

    context 'when an error is raised' do
      before(:each) do
        allow_any_instance_of(Minimart::Commands::Mirror).to receive(:execute!).and_raise Minimart::Error::BaseError
      end

      it 'should handle the error' do
        expect(Minimart::Error).to receive(:handle_exception)

        Minimart::Cli.start %w[mirror --inventory_config=./my-test.yml --inventory_directory=./test-dir]
      end
    end
  end

  describe '#web' do
    let(:command_double) { instance_double(Minimart::Commands::Web, execute!: true) }

    it 'should call the web command with the proper arguments' do
      expect(Minimart::Commands::Web).to receive(:new).with(
        'web_directory'       => './web',
        'inventory_directory' => './inventory',
        'host'                => 'http://example.com',
        'html'                => true).and_return command_double

      Minimart::Cli.start %w[web --host=http://example.com]
    end

    it 'should allow users to override defaults' do
      expect(Minimart::Commands::Web).to receive(:new).with(
        'web_directory'       => './my-web',
        'inventory_directory' => './my-inventory',
        'host'                => 'http://example.com',
        'html'                => false).and_return command_double

      Minimart::Cli.start %w[
        web
        --host=http://example.com
        --web-directory=./my-web
        --inventory-directory=./my-inventory
        --no-html]
    end

    context 'when an error is raised' do
      before(:each) do
        allow_any_instance_of(Minimart::Commands::Web).to receive(:execute!).and_raise Minimart::Error::BaseError
      end

      it 'should handle the error' do
        expect(Minimart::Error).to receive(:handle_exception)

        Minimart::Cli.start %w[
          web
          --host=http://example.com
          --web-directory=./my-web
          --inventory-directory=./my-inventory
          --no-html]
      end
    end
  end
end
