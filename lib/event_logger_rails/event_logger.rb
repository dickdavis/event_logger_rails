# frozen_string_literal: true

require_relative 'event'
require_relative 'exceptions/invalid_logger_level'
require_relative 'exceptions/unregistered_event'

module EventLoggerRails
  ##
  # Outputs event and related data logs.
  class EventLogger
    def initialize(logdev:, logger_class:)
      @logger = logger_class.new(logdev)
      @logger.formatter = proc do |level, timestamp, _progname, message|
        "#{JSON.dump(structured_output(level:, timestamp:, message:))}\n"
      end
    end

    def log(event, level, data = {})
      event = event.is_a?(EventLoggerRails::Event) ? event : EventLoggerRails::Event.new(event)
      raise EventLoggerRails::Exceptions::UnregisteredEvent.new(unregistered_event: event) unless event.valid?

      log_message(event, level, data)
    rescue EventLoggerRails::Exceptions::UnregisteredEvent,
           EventLoggerRails::Exceptions::InvalidLoggerLevel => error
      log(error.event, :error, { message: error.message })
    end

    private

    attr_reader :logger

    def log_message(event, level, data)
      logger.send(level) do
        filtered_data = ActiveSupport::ParameterFilter.new(EventLoggerRails.sensitive_fields).filter(data)
        { event_identifier: event.identifier, event_description: event.description }.merge(filtered_data)
      end
    rescue NoMethodError
      raise EventLoggerRails::Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end

    def structured_output(level:, timestamp:, message:)
      {
        host: Socket.gethostname,
        environment: Rails.env,
        service_name: Rails.application.class.module_parent_name,
        level:,
        timestamp: timestamp.iso8601(3),
        **message
      }
    end
  end
end
