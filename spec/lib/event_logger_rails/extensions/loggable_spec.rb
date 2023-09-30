# frozen_string_literal: true

require 'rails_helper'

##
# Dummy class for testing
class DummyClass
  include EventLoggerRails::Extensions::Loggable

  def test_one
    log_event 'event_logger_rails.event.testing'
  end

  def test_two
    log_event 'event_logger_rails.event.testing', data: { test: 'two' }
  end

  def test_three
    log_event 'event_logger_rails.event.testing', level: :info
  end

  private

  def optional_data
    {
      foo: 'bar'
    }
  end
end

RSpec.describe EventLoggerRails::Extensions::Loggable do
  let(:object) { DummyClass.new }

  let(:logger_spy) { instance_spy(EventLoggerRails::EventLogger) }

  before do
    allow(EventLoggerRails::EventLogger).to receive(:new).and_return(logger_spy)
  end

  context 'without additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_one
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :warn,
          { foo: 'bar' }
        )
    end
  end

  context 'with additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_two
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :warn,
          { foo: 'bar', test: 'two' }
        )
    end
  end

  context 'with optional logger level provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_three
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :info,
          { foo: 'bar' }
        )
    end
  end
end
