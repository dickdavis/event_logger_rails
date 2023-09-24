# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails do
  subject(:engine) { described_class }

  describe '.setup' do
    subject(:engine_setup) do
      engine.setup do |config|
        config.registered_events = events
      end
    end

    let(:events) { 'foo' }

    it 'configures the registered events' do
      engine_setup
      expect(described_class.registered_events).to eq(events)
    end
  end
end
