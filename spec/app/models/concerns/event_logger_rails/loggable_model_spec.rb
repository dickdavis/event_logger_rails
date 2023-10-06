# frozen_string_literal: true

require 'rails_helper'

##
# Dummy model for testing
class DummyModel
  include ActiveModel::Model
  include EventLoggerRails::LoggableModel

  attr_reader :id

  def initialize
    super
    @id = 42
  end

  def test
    log_event 'event_logger_rails.event.testing'
  end
end

RSpec.describe EventLoggerRails::LoggableModel, type: :model do
  let(:model_instance) { DummyModel.new }
  let(:data_from_model) do
    {
      model: model_instance.class.name,
      instance_id: model_instance.id
    }
  end

  let(:emitter_spy) { instance_spy(EventLoggerRails::Emitter) }

  before do
    allow(EventLoggerRails::Emitter).to receive(:new).and_return(emitter_spy)
  end

  after do
    EventLoggerRails.reset
  end

  it 'calls the emitter with data from the model' do
    model_instance.test
    expect(emitter_spy)
      .to have_received(:log)
      .with(
        'event_logger_rails.event.testing',
        level: nil,
        data: hash_including(data_from_model)
      )
  end
end
