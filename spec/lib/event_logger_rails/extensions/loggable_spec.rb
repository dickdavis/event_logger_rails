# frozen_string_literal: true

require 'rails_helper'

##
# Dummy class for testing
class DummyClass
  include EventLoggerRails::Extensions::Loggable

  def test_one
    trace_and_log_event 'event_logger_rails.event.testing' do
      trace_test_one
    end
  end

  def test_two
    log_event 'event_logger_rails.event.testing'
  end

  def test_three
    log_event 'event_logger_rails.event.testing', test: 'two'
  end

  def test_four
    log_event 'event_logger_rails.event.testing', :info
  end

  private

  def trace_test_one
    trace_test_two(:foo)
  end

  def trace_test_two(param)
    trace_test_three(param, 'bar', { 'foo' => :bar })
  end

  def trace_test_three(foo, bar, baz)
    [foo, bar, baz]
  end

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

  context 'with tracing' do
    before { EventLoggerRails.reset }

    # rubocop:disable RSpec/ExampleLength
    it 'calls the event logger' do
      object.test_one
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :warn,
          {
            foo: 'bar',
            trace: [
              hash_including(
                class: DummyClass,
                method: :trace_test_one,
                parameters: [],
                path: anything
              ),
              hash_including(
                class: DummyClass,
                method: :trace_test_two,
                parameters: [%i[req param foo]],
                path: anything
              ),
              hash_including(
                class: DummyClass,
                method: :trace_test_three,
                parameters: [%i[req foo foo], [:req, :bar, 'bar'], [:req, :baz, { 'foo' => :bar }]],
                path: anything
              )
            ]
          }
        )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context 'without additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_two
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :warn,
          { trace: [], foo: 'bar' }
        )
    end
  end

  context 'with additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_three
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :warn,
          { trace: [], foo: 'bar', test: 'two' }
        )
    end
  end

  context 'with optional logger level provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      object.test_four
      expect(logger_spy)
        .to have_received(:log)
        .with(
          'event_logger_rails.event.testing',
          :info,
          { trace: [], foo: 'bar' }
        )
    end
  end
end
