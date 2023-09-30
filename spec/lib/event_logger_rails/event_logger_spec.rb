# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::EventLogger do
  subject(:event_logger) do
    described_class.new(logdev: File.open(File::NULL, 'w'), logger_class: Logger)
  end

  describe '#log' do
    subject(:method_call) { event_logger.log(event, level, **data) }

    let(:event) { EventLoggerRails::Event.new('event_logger_rails.event.testing') }
    let(:level) { :warn }
    let(:data) { { foo: 'bar' } }

    let(:buffer) { StringIO.new }

    before do
      allow(IO).to receive(:open).and_return(buffer)
      EventLoggerRails::CurrentRequest.id = '1234'
      EventLoggerRails::CurrentRequest.format = 'text/html'
      EventLoggerRails::CurrentRequest.method = 'GET'
      EventLoggerRails::CurrentRequest.parameters = { foo: 'bar' }
      EventLoggerRails::CurrentRequest.path = '/'
      EventLoggerRails::CurrentRequest.remote_ip = '10.1.1.1'
    end

    # rubocop:disable RSpec/ExampleLength
    it 'logs the default severity, timestamp, event identifier, description, and data' do
      method_call
      log_output = JSON.parse(buffer.string, symbolize_names: true)
      expect(log_output).to include(
        environment: 'test',
        event_description: event.description,
        event_identifier: event.identifier,
        format: 'text/html',
        host: anything,
        id: '1234',
        level: 'WARN',
        method: 'GET',
        parameters: { foo: 'bar' },
        path: '/',
        remote_ip: '10.1.1.1',
        service_name: 'Dummy',
        timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/),
        **data
      )
    end
    # rubocop:enable RSpec/ExampleLength

    context 'when sensitive data is provided' do
      let(:data) { { password: 'foobar' } }
      let(:filtered_data) { { password: '[FILTERED]' } }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the default severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          environment: 'test',
          event_description: event.description,
          event_identifier: event.identifier,
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'WARN',
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/),
          **filtered_data
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when an identifier is provided instead of an EventLoggerRails::Event object' do
      let(:event) { 'event_logger_rails.event.testing' }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the severity, timestamp, event identifier, description, and data' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          environment: 'test',
          event_description: 'Event reserved for testing.',
          event_identifier: 'event_logger_rails.event.testing',
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'WARN',
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/),
          **data
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
          environment: 'test',
          event_description: 'Indicates provided event was unregistered.',
          event_identifier: 'event_logger_rails.event.unregistered',
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'ERROR',
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
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
          environment: 'test',
          event_description: event.description,
          event_identifier: event.identifier,
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'INFO',
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
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
          environment: 'test',
          event_description: 'Indicates provided level was invalid.',
          event_identifier: 'event_logger_rails.logger_level.invalid',
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'ERROR',
          message: "Invalid logger level provided: 'foo'. Valid levels: :debug, :info, :warn, :error, :unknown.",
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when data is not provided' do
      subject(:method_call) { event_logger.log(event, level) }

      # rubocop:disable RSpec/ExampleLength
      it 'logs the default severity, timestamp, event identifier, and description' do
        method_call
        log_output = JSON.parse(buffer.string, symbolize_names: true)
        expect(log_output).to include(
          environment: 'test',
          event_description: event.description,
          event_identifier: event.identifier,
          format: 'text/html',
          host: anything,
          id: '1234',
          level: 'WARN',
          method: 'GET',
          parameters: { foo: 'bar' },
          path: '/',
          remote_ip: '10.1.1.1',
          service_name: 'Dummy',
          timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
