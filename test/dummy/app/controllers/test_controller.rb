# frozen_string_literal: true

class TestController < ApplicationController
  include EventLoggerRails::Loggable

  def show
    log_event :info, 'testing.event'
    render json: { message: 'It works.' }, status: :ok
  end
end
