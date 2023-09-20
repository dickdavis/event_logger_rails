# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::EventLogger do
  subject(:event_logger) { described_class.new }

  describe '#log' do
    subject(:method_call) { event_logger.log(level, event, **data) }

    let(:level) { instance_double(EventLoggerRails::Level, to_s: 'info', to_sym: :info, valid?: true) }
    let(:event) { instance_double(EventLoggerRails::Event, to_s: 'foo.bar', valid?: true) }
    let(:data) { { foo: 'bar' } }

    let(:output_spy) { instance_spy(File) }

    before do
      allow(EventLoggerRails::Level).to receive(:new).and_return(level)
      allow(EventLoggerRails::Event).to receive(:new).and_return(event)
      allow(File).to receive(:open).and_return(output_spy)
    end

    it 'logs the data with the level, datetime, and event tags' do
      method_call
      date_regexp = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}/
      expect(output_spy)
        .to have_received(:write)
        .with(/\[(#{level.to_s.upcase}) \| #{date_regexp} \| (#{event})\] (#{data.as_json})/)
    end

    context 'when an identifier is provided instead of an EventLoggerRails::Event object' do
      let(:event) { 'event_logger_rails.event.testing' }

      before do
        allow(EventLoggerRails::Event).to receive(:new).and_call_original
      end

      it 'logs the data with the level, datetime, and event tags' do
        method_call
        date_regexp = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}/
        expect(output_spy)
          .to have_received(:write)
          .with(/\[(#{level.to_s.upcase}) \| #{date_regexp} \| (#{event})\] (#{data.as_json})/)
      end
    end

    context 'when a level symbol is provided instead of an EventLoggerRails::Level object' do
      let(:level) { :info }

      before do
        allow(EventLoggerRails::Level).to receive(:new).and_call_original
      end

      it 'logs the data with the level, datetime, and event tags' do
        method_call
        date_regexp = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}/
        expect(output_spy)
          .to have_received(:write)
          .with(/\[(#{level.to_s.upcase}) \| #{date_regexp} \| (#{event})\] (#{data.as_json})/)
      end
    end

    context 'when the level is not valid' do
      let(:level) { instance_double(EventLoggerRails::Level, to_s: 'info', to_sym: :info, valid?: false) }

      it 'does not output a log entry' do
        begin
          method_call
        rescue EventLoggerRails::Exceptions::InvalidLoggerLevel
          nil
        end
        expect(output_spy).not_to have_received(:write)
      end

      it 'raises an error' do
        expect { method_call }.to raise_error(EventLoggerRails::Exceptions::InvalidLoggerLevel)
      end

      it 'initializes the error with the logger level' do
        allow(EventLoggerRails::Exceptions::InvalidLoggerLevel).to receive(:new).and_call_original

        begin
          method_call
        rescue EventLoggerRails::Exceptions::InvalidLoggerLevel
          nil
        end

        expect(EventLoggerRails::Exceptions::InvalidLoggerLevel).to have_received(:new).with(logger_level: level)
      end
    end

    context 'when the event is not valid' do
      let(:event) { instance_double(EventLoggerRails::Event, to_s: 'foo.bar', valid?: false) }

      it 'does not output a log entry' do
        begin
          method_call
        rescue EventLoggerRails::Exceptions::UnregisteredEvent
          nil
        end
        expect(output_spy).not_to have_received(:write)
      end

      it 'raises an error' do
        expect { method_call }.to raise_error(EventLoggerRails::Exceptions::UnregisteredEvent)
      end

      it 'initializes the error with the event' do
        allow(EventLoggerRails::Exceptions::UnregisteredEvent).to receive(:new).and_call_original

        begin
          method_call
        rescue EventLoggerRails::Exceptions::UnregisteredEvent
          nil
        end

        expect(EventLoggerRails::Exceptions::UnregisteredEvent)
          .to have_received(:new)
          .with(unregistered_event: event)
      end
    end
  end
end
