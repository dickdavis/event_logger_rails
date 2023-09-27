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

  let(:logger_spy) { instance_spy(EventLoggerRails::EventLogger) }

  before do
    allow(EventLoggerRails::EventLogger).to receive(:new).and_return(logger_spy)
  end

  after do
    EventLoggerRails.reset
  end

  it 'calls the event logger with data from the model' do
    model_instance.test
    expect(logger_spy)
      .to have_received(:log)
      .with(
        'event_logger_rails.event.testing',
        :warn,
        hash_including(data_from_model)
      )
  end
end
