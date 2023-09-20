# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails do
  subject(:engine) { described_class }

  describe '.setup' do
    subject(:engine_setup) do
      engine.setup do |config|
        config.registered_events = events
        config.logger_levels = levels
      end
    end

    let(:events) { 'foo' }
    let(:levels) { 'bar' }

    it 'configures the registered events' do
      engine_setup
      expect(described_class.registered_events).to eq(events)
    end

    it 'configures the logger levels' do
      engine_setup
      expect(described_class.logger_levels).to eq(levels)
    end
  end
end
