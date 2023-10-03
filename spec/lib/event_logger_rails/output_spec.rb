# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Output do
  subject(:output) { described_class.new(level:, timestamp:, message:) }

  let(:level) { 'WARN' }
  let(:timestamp) { Time.zone.now }

  describe '#to_json' do
    subject(:method_call) { output.to_json }

    let(:message) { { test: 'foobar' } }

    before do
      EventLoggerRails::CurrentRequest.id = '1234'
      EventLoggerRails::CurrentRequest.format = 'text/html'
      EventLoggerRails::CurrentRequest.method = 'GET'
      EventLoggerRails::CurrentRequest.parameters = { foo: 'bar' }
      EventLoggerRails::CurrentRequest.path = '/'
      EventLoggerRails::CurrentRequest.remote_ip = '10.1.1.1'
    end

    # rubocop:disable RSpec/ExampleLength
    it 'returns a stringified JSON object containing the serialized output data' do
      result = JSON.parse(method_call, symbolize_names: true)
      expect(result).to include(
        environment: 'test',
        format: 'text/html',
        host: anything,
        id: '1234',
        level:,
        method: 'GET',
        parameters: { foo: 'bar' },
        path: '/',
        remote_ip: '10.1.1.1',
        service_name: 'Dummy',
        test: 'foobar',
        timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#to_hash' do
    subject(:method_call) { output.to_hash }

    context 'when the data from the current request is not available' do
      before do
        EventLoggerRails::CurrentRequest.reset
      end

      context 'when message can be coerced to hash' do
        let(:message) { { test: 'foobar' } }

        it 'returns a hash containing level, formatted timestamp, and key/values from the message' do
          expect(method_call).to include(
            environment: 'test',
            host: anything,
            level:,
            service_name: 'Dummy',
            test: 'foobar',
            timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
          )
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when sensitive data is provided in the message hash' do
          let(:message) { { password: 'foobar' } }
          let(:filtered_message) { { password: '[FILTERED]' } }

          it 'returns a hash containing level, formatted timestamp, and filtered message key/values' do
            expect(method_call).to include(
              environment: 'test',
              host: anything,
              level:,
              service_name: 'Dummy',
              timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/),
              **filtered_message
            )
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'when message cannot be coerced to hash' do
        let(:message) { 'foobar' }

        it 'returns a hash containing level, formatted timestamp, and key/values from the message' do
          expect(method_call).to include(
            environment: 'test',
            host: anything,
            level:,
            message: 'foobar',
            service_name: 'Dummy',
            timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
          )
        end
      end
    end

    context 'when the data from the current request is available' do
      before do
        EventLoggerRails::CurrentRequest.id = '1234'
        EventLoggerRails::CurrentRequest.format = 'text/html'
        EventLoggerRails::CurrentRequest.method = 'GET'
        EventLoggerRails::CurrentRequest.parameters = { foo: 'bar' }
        EventLoggerRails::CurrentRequest.path = '/'
        EventLoggerRails::CurrentRequest.remote_ip = '10.1.1.1'
      end

      context 'when message can be coerced to hash' do
        let(:message) { { test: 'foobar' } }

        # rubocop:disable RSpec/ExampleLength
        it 'returns a hash containing level, formatted timestamp, request details, and key/values from the message' do
          expect(method_call).to include(
            environment: 'test',
            format: 'text/html',
            host: anything,
            id: '1234',
            level:,
            method: 'GET',
            parameters: { foo: 'bar' },
            path: '/',
            remote_ip: '10.1.1.1',
            service_name: 'Dummy',
            test: 'foobar',
            timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
          )
        end
        # rubocop:enable RSpec/ExampleLength

        # rubocop:disable RSpec/NestedGroups
        context 'when sensitive data is provided in the message hash' do
          let(:message) { { password: 'foobar' } }
          let(:filtered_message) { { password: '[FILTERED]' } }

          # rubocop:disable RSpec/ExampleLength
          it 'returns a hash containing level, formatted timestamp, request details, and filtered message key/values' do
            expect(method_call).to include(
              environment: 'test',
              format: 'text/html',
              host: anything,
              id: '1234',
              level:,
              method: 'GET',
              parameters: { foo: 'bar' },
              path: '/',
              remote_ip: '10.1.1.1',
              service_name: 'Dummy',
              timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/),
              **filtered_message
            )
          end
          # rubocop:enable RSpec/ExampleLength
        end

        context 'when sensitive data is provided in the parameters' do
          let(:parameters) { { password: 'foobar' } }
          let(:filtered_parameters) { { password: '[FILTERED]' } }

          before do
            EventLoggerRails::CurrentRequest.parameters = parameters
          end

          # rubocop:disable RSpec/ExampleLength
          it 'returns a hash containing level, formatted timestamp, filtered request details, and message key/values' do
            expect(method_call).to include(
              environment: 'test',
              format: 'text/html',
              host: anything,
              id: '1234',
              level:,
              method: 'GET',
              parameters: filtered_parameters,
              path: '/',
              remote_ip: '10.1.1.1',
              service_name: 'Dummy',
              test: 'foobar',
              timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
            )
          end
          # rubocop:enable RSpec/ExampleLength
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'when message cannot be coerced to hash' do
        let(:message) { 'foobar' }

        # rubocop:disable RSpec/ExampleLength
        it 'returns a hash containing level, formatted timestamp, request details, and key/values from the message' do
          expect(method_call).to include(
            environment: 'test',
            format: 'text/html',
            host: anything,
            id: '1234',
            level:,
            message: 'foobar',
            method: 'GET',
            parameters: { foo: 'bar' },
            path: '/',
            remote_ip: '10.1.1.1',
            service_name: 'Dummy',
            timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
          )
        end
        # rubocop:enable RSpec/ExampleLength

        # rubocop:disable RSpec/NestedGroups
        context 'when sensitive data is provided in the parameters' do
          let(:parameters) { { password: 'foobar' } }
          let(:filtered_parameters) { { password: '[FILTERED]' } }

          before do
            EventLoggerRails::CurrentRequest.parameters = parameters
          end

          # rubocop:disable RSpec/ExampleLength
          it 'returns a hash containing level, formatted timestamp, filtered request details, and message key/values' do
            expect(method_call).to include(
              environment: 'test',
              format: 'text/html',
              host: anything,
              id: '1234',
              level:,
              message: 'foobar',
              method: 'GET',
              parameters: filtered_parameters,
              path: '/',
              remote_ip: '10.1.1.1',
              service_name: 'Dummy',
              timestamp: match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)?\z/)
            )
          end
          # rubocop:enable RSpec/ExampleLength
        end
        # rubocop:enable RSpec/NestedGroups
      end
    end
  end
end
