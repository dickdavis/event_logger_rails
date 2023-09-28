# frozen_string_literal: true

class TestController < ApplicationController
  include EventLoggerRails::LoggableController

  def show
    log_event 'user.login.failure', :info
    render json: { message: 'It works.' }, status: :ok
  end
end
