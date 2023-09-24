# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Exceptions::InvalidLoggerLevel do
  subject(:exception) { described_class.new(logger_level:) }

  let(:logger_level) { :foobar }

  it 'returns the event reserved for the exception' do
    expect(exception.event).to eq('event_logger_rails.logger_level.invalid')
  end

  it 'returns a message with the invalid logger level as well as the valid logger levels' do
    expect(exception.message).to eq(
      "Invalid logger level provided: '#{logger_level.to_sym}'. Valid levels: :debug, :info, :warn, :error, :unknown."
    )
  end
end
