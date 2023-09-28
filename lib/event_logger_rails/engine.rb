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
    config.event_logger_rails.logger_class = Logger

    config.after_initialize do |app|
      EventLoggerRails.setup do |engine|
        engine.registered_events = Rails.application.config_for(:event_logger_rails)
        engine.logdev = app.config.event_logger_rails.logdev
        engine.logger_class = app.config.event_logger_rails.logger_class
      end
    end
  end
end
