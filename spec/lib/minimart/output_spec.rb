require 'spec_helper'

describe Minimart::Output do

  let(:io) { StringIO.new }
  let(:output) { Minimart::Output.new(io) }

  subject { io.string }

  describe '#puts' do
    before(:each) { output.puts 'hello world' }
    it { is_expected.to include 'hello world' }
  end

  describe '#puts_red' do
    before(:each) { output.puts_red 'hello world' }
    it { is_expected.to include "\e[31mhello world\e[0m" }
  end

  describe '#puts_green' do
    before(:each) { output.puts_green 'hello world' }
    it { is_expected.to include "\e[32mhello world\e[0m" }
  end

  describe '#puts_yellow' do
    before(:each) { output.puts_yellow 'hello world' }
    it { is_expected.to include "\e[33mhello world\e[0m" }
  end
end
