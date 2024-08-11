# frozen_string_literal: true

module EventLoggerRails
  # Engine for plugging into Rails.
  class Engine < ::Rails::Engine
    # Use the EventLoggerRails namespace.
    isolate_namespace EventLoggerRails

    # Use the rspec test framework.
    config.generators do |generator|
      generator.test_framework :rspec
    end

    # Initialize the EventLoggerRails configuration.
    config.event_logger_rails = ActiveSupport::OrderedOptions.new
    config.event_logger_rails.formatter = 'EventLoggerRails::Formatters::JSON'
    config.event_logger_rails.logdev = "log/event_logger_rails.#{Rails.env}.log"
    config.event_logger_rails.logger_class = 'EventLoggerRails::EventLogger'
    config.event_logger_rails.default_level = :warn

    # Add the EventLoggerRails middleware.
    initializer 'event_logger_rails.add_middleware' do |app|
      # Use middleware to capture the request details.
      app.middleware.use Middleware::CaptureRequestDetails
    end

    # Configure EventLoggerRails
    config.after_initialize do |app|
      EventLoggerRails.setup do |engine|
        # Set the default logging level from the registration.
        engine.default_level = app.config.event_logger_rails.default_level
        # Set the formatter.
        engine.formatter = app.config.event_logger_rails.formatter
        # Set the log device.
        engine.logdev = app.config.event_logger_rails.logdev
        # Set the logger class.
        engine.logger_class = app.config.event_logger_rails.logger_class
        # Set the registered events from the registration.
        engine.registered_events = Rails.application.config_for(:event_logger_rails)
        # Set the sensitive fields.
        engine.sensitive_fields = app.config.filter_parameters
      end
    end
  end
end
