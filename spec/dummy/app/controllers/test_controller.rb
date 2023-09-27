# frozen_string_literal: true

class TestController < ApplicationController
  include EventLoggerRails::LoggableController

  def show
    log_event :info, 'user.login.failure'
    render json: { message: 'It works.' }, status: :ok
  end
end
