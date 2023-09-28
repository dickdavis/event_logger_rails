# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::EventLogger do
  subject(:event_logger) { described_class.new(output_device: File.open(File::NULL, 'w')) }

  describe '#log' do
    subject(:method_call) { event_logger.log(event, level, **data) }

    let(:event) { EventLoggerRails::Event.new('event_logger_rails.event.testing') }
    let(:level) { :warn }
    let(:data) { { foo: 'bar' } }

    let(:buffer) { StringIO.new }

    before do
      allow(IO).to receive(:open).and_return(buffer)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'logs the default severity, timestamp, event identifier, description, and data' do
      method_call
      log_output = JSON.parse(buffer.string, symbolize_names: true)
      expect(log_output).to include(
        message: include(
          event_description: event.description,
          event_identifier: event.identifier,
          **data
        ),
        severity: 'WARN',
        timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
      )
    end
    # rubocop:enable RSpec/ExampleLength

    context 'when an identifier is provided instead of an EventLoggerRails::Event object' do
      let(:event) { 'event_logger_rails.event.testing' }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          message: include(
            event_description: 'Event reserved for testing.',
            event_identifier: 'event_logger_rails.event.testing',
            **data
          ),
          severity: 'WARN',
          timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when the event is not valid' do
      let(:event) { EventLoggerRails::Event.new('foo.bar') }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          message: include(
            event_description: 'Indicates provided event was unregistered.',
            event_identifier: 'event_logger_rails.event.unregistered',
            message: 'Event provided not registered: foo.bar'
          ),
          severity: 'ERROR',
          timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when a valid logger level is provided' do
      let(:level) { :info }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the provided severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          message: include(
            event_description: event.description,
            event_identifier: event.identifier,
            **data
          ),
          severity: 'INFO',
          timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when the logger level is not valid' do
      let(:level) { :foo }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          message: include(
            event_description: 'Indicates provided level was invalid.',
            event_identifier: 'event_logger_rails.logger_level.invalid',
            message: "Invalid logger level provided: 'foo'. Valid levels: :debug, :info, :warn, :error, :unknown."
          ),
          severity: 'ERROR',
          timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when data is not provided' do
      subject(:method_call) { event_logger.log(event, level) }

      it 'logs the default severity, timestamp, event identifier, and description' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          message: include(
            event_description: event.description,
            event_identifier: event.identifier
          ),
          severity: 'WARN',
          timestamp: match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
        )
      end
    end
  end
end
