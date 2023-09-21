# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Exceptions::UnregisteredEvent do
  subject(:exception) { described_class.new(unregistered_event:) }

  let(:unregistered_event) { instance_double(EventLoggerRails::Event, to_s: 'foobar') }

  before do
    EventLoggerRails.setup do |config|
      config.registered_events = 'foo.bar.baz'
    end
  end

  it 'returns the event reserved for the exception' do
    expect(exception.event).to eq('event_logger_rails.event.unregistered')
  end

  it 'returns a message with the unregistered event' do
    expect(exception.message).to eq("Event provided not registered: #{unregistered_event}")
  end
end
