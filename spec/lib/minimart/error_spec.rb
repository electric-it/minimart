require 'spec_helper'

describe Minimart::Error do
  describe '::handle_exception' do
    let(:ex) { StandardError.new('test error msg') }

    it 'should print the error' do
      begin; subject.handle_exception(ex); rescue SystemExit; end
      expect(Minimart::Configuration.output.io.string).to include 'test error msg'
    end

    it 'should exit with a failure status code' do
      expect {
        subject.handle_exception(ex)
      }.to raise_error SystemExit
    end
  end
end
