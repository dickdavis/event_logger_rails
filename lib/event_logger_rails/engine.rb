# frozen_string_literal: true

module EventLoggerRails
  ##
  # Engine for plugging into Rails
  class Engine < ::Rails::Engine
    isolate_namespace EventLoggerRails

    config.generators do |generator|
      generator.test_framework :rspec
    end

    config.event_logger_rails = ActiveSupport::OrderedOptions.new
    config.event_logger_rails.logdev = "log/event_logger_rails.#{Rails.env}.log"
    config.event_logger_rails.default_level = :warn

    initializer 'event_logger_rails.add_middleware' do |app|
      app.middleware.use Middleware::CaptureRequestDetails
    end

    config.after_initialize do |app|
      EventLoggerRails.setup do |engine|
        engine.default_level = app.config.event_logger_rails.default_level
        engine.logdev = app.config.event_logger_rails.logdev
        engine.registered_events = Rails.application.config_for(:event_logger_rails)
        engine.sensitive_fields = app.config.filter_parameters
      end
    end
  end
end
