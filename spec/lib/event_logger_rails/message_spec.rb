# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Message do
  subject(:message) { described_class.new(**options) }

  let(:options) { { event:, data: try(:data) }.compact }

  describe '#to_hash' do
    subject(:method_call) { message.to_hash }

    context 'when provided a valid event' do
      let(:event) { EventLoggerRails::Event.new('event_logger_rails.event.testing') }

      context 'without data' do
        let(:data) { nil }

        it 'returns the details from the event hash' do
          expect(method_call).to eq(event.to_hash)
        end
      end

      context 'with data' do
        let(:data) { { foo: 'bar' } }

        it 'returns details from the event hash' do
          expect(method_call).to include(**event)
        end

        it 'returns details from the data hash' do
          expect(method_call).to include(**data)
        end
      end
    end

    context 'when provided an invalid event (does not respond to `merge`)' do
      let(:event) { 'foo.bar.baz' }

      it 'raises a NoMethodError' do
        expect { method_call }.to raise_error(NoMethodError)
      end
    end
  end
end
