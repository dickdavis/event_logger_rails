# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails do
  subject(:engine) { described_class }

  describe '.setup' do
    describe 'registered events' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.registered_events = events
        end
      end

      let(:events) { 'foobar' }

      it 'configures the registered events' do
        engine_setup
        expect(described_class.registered_events).to eq(events)
      end
    end

    describe 'logdev' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.logdev = logdev
        end
      end

      let(:logdev) { File.open(File::NULL, 'w') }

      it 'configures the output device to use for initializing the logger' do
        engine_setup
        expect(described_class.logdev).to eq(logdev)
      end
    end

    describe 'logger_class' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.logger_class = logger_class
        end
      end

      let(:logger_class) { Logger }

      it 'configures the class to use for initializing the logger' do
        engine_setup
        expect(described_class.logger_class).to eq(logger_class)
      end
    end
  end

  describe '.event_logger' do
    before { described_class.reset }

    it 'returns the EventLogger' do
      expect(engine.event_logger).to be_a(EventLoggerRails::EventLogger)
    end
  end

  describe '.reset' do
    before { described_class.reset }

    it 'sets the event_logger to nil' do
      engine.event_logger
      expect { engine.reset }.to change { engine.instance_variable_get(:@event_logger) }.to(nil)
    end
  end
end
