# frozen_string_literal: true

require_relative 'event'
require_relative 'exceptions/invalid_logger_level'
require_relative 'exceptions/unregistered_event'

module EventLoggerRails
  ##
  # Outputs event and related data logs.
  class EventLogger
    def initialize(output_device: $stdout)
      @logger = Logger.new(output_device)
      @logger.formatter = proc do |severity, datetime, _progname, message|
        JSON.dump(severity:, timestamp: datetime.to_s, message:)
      end
    end

    def log(event, level, data = {})
      event = event.is_a?(EventLoggerRails::Event) ? event : EventLoggerRails::Event.new(event)
      raise EventLoggerRails::Exceptions::UnregisteredEvent.new(unregistered_event: event) unless event.valid?

      log_message(event, level, **data)
    rescue EventLoggerRails::Exceptions::UnregisteredEvent,
           EventLoggerRails::Exceptions::InvalidLoggerLevel => error
      log(error.event, :error, message: error.message)
    end

    private

    attr_reader :logger

    def log_message(event, level, **data)
      logger.send(level) do
        { event_identifier: event.identifier, event_description: event.description }.merge(data)
      end
    rescue NoMethodError
      raise EventLoggerRails::Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end
  end
end
