# frozen_string_literal: true

require 'rails_helper'

##
# Dummy controller for testing
class DummyController < ActionController::Base
  include EventLoggerRails::LoggableController

  def test_one
    log_event 'event_logger_rails.event.testing'
    head :no_content
  end

  def test_two
    log_event 'event_logger_rails.event.testing', test: 'two'
    head :no_content
  end

  def test_three
    log_event 'event_logger_rails.event.testing', :info
    head :no_content
  end
end

RSpec.describe EventLoggerRails::LoggableController, type: :request do
  let(:params) { { 'foo' => 'bar' } }
  let(:data_from_controller) do
    {
      action: controller.action_name,
      controller: controller.controller_name.camelcase
    }
  end

  let(:emitter_spy) { instance_spy(EventLoggerRails::Emitter) }

  before do
    allow(EventLoggerRails::Emitter).to receive(:new).and_return(emitter_spy)

    Rails.application.routes.draw do
      get :test_one, to: 'dummy#test_one', as: :test_one
      get :test_two, to: 'dummy#test_two', as: :test_two
      get :test_three, to: 'dummy#test_three', as: :test_three
    end
  end

  after do
    EventLoggerRails.reset
  end

  it 'calls the emitter with data from the controller' do
    get(test_one_path, params:)
    expect(emitter_spy)
      .to have_received(:log)
      .with(
        'event_logger_rails.event.testing',
        level: nil,
        data: hash_including(data_from_controller)
      )
  end
end
