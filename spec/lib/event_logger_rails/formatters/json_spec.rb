# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Formatters::JSON do
  subject(:formatter) { described_class.new }

  describe '#call' do
    subject(:method_call) { formatter.call(level, timestamp, progname, message) }

    let(:level) { :foo }
    let(:timestamp) { Time.now }
    let(:progname) { 'bar' }
    let(:message) { { foo: 'bar' } }

    it 'returns the event reserved for the exception' do
      expected_output = EventLoggerRails::Output.new(level:, timestamp:, message:).to_json
      expect(method_call).to eq("#{expected_output}\n")
    end
  end
end
