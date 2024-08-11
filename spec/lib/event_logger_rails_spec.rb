# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails do
  subject(:engine) { described_class }

  describe '.setup' do
    describe 'default_level' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.default_level = default_level
        end
      end

      let(:default_level) { :info }

      it 'configures the default level for the logger' do
        engine_setup
        expect(described_class.default_level).to eq(default_level)
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

    describe 'formatter' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.formatter = formatter_class
        end
      end

      let(:formatter_class) { 'EventLoggerRails::Formatters::JSON' }

      it 'configures the formatter to use for initializing the logger' do
        engine_setup
        expect(described_class.formatter).to eq(formatter_class)
      end
    end

    describe 'logger_class' do
      subject(:engine_setup) do
        engine.setup do |config|
          config.logger_class = logger_class
        end
      end

      let(:logger_class) { 'EventLoggerRails::EventLogger' }

      it 'configures the output device to use for initializing the logger' do
        engine_setup
        expect(described_class.logger_class).to eq(logger_class)
      end
    end

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
  end

  describe '.emitter' do
    before { described_class.reset }

    it 'returns the emitter' do
      expect(engine.emitter).to be_a(EventLoggerRails::Emitter)
    end
  end

  describe '.reset' do
    before { described_class.reset }

    it 'sets the emitter to nil' do
      engine.emitter
      expect { engine.reset }.to change { engine.instance_variable_get(:@emitter) }.to(nil)
    end
  end
end
