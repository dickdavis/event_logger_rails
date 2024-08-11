# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::EventLogger do
  subject(:event_logger) { described_class.new(File.open(File::NULL, 'w')) }

  let(:message) { { foo: 'bar' } }
  let(:buffer) { StringIO.new }

  before do
    allow(IO).to receive(:open).and_return(buffer)
  end

  context 'when default formatter is configured' do
    it 'outputs the provided message in JSON format' do
      event_logger.info(message)
      log_output = JSON.parse(buffer.string, symbolize_names: true)
      expect(log_output).to include(**message)
    end
  end
end
