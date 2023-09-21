# frozen_string_literal: true

require 'rails_helper'

class DummyController < ActionController::Base
  include EventLoggerRails::Loggable

  def test_one
    log_event :info, 'event_logger_rails.event.testing'
    head :no_content
  end

  def test_two
    log_event :info, 'event_logger_rails.event.testing', test: 'two'
    head :no_content
  end
end

RSpec.describe EventLoggerRails::Loggable, type: :request do
  let(:params) { { foo: 'bar' } }
  let(:data_from_request) do
    {
      action: controller.action_name,
      controller: controller.controller_name.camelcase,
      method: request.method,
      parameters: params.to_json,
      path: request.path,
      remote_ip: request.remote_ip
    }
  end

  let(:logger_spy) { instance_spy(EventLoggerRails::EventLogger) }

  before do
    allow(EventLoggerRails::EventLogger).to receive(:new).and_return(logger_spy)

    Rails.application.routes.draw do
      get :test_one, to: 'dummy#test_one', as: :test_one
      get :test_two, to: 'dummy#test_two', as: :test_two
    end

    EventLoggerRails.setup do |config|
      config.logger_levels = %i[info]
    end
  end

  context 'without additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      get(test_one_path, params:)
      expect(logger_spy)
        .to have_received(:log)
        .with(
          :info,
          'event_logger_rails.event.testing',
          data_from_request
        )
    end
  end

  context 'with additional data provided' do
    before { EventLoggerRails.reset }

    it 'calls the event logger' do
      get(test_two_path, params:)
      expect(logger_spy)
        .to have_received(:log)
        .with(
          :info,
          'event_logger_rails.event.testing',
          data_from_request.merge({ test: 'two' })
        )
    end
  end
end
