# frozen_string_literal: true

module EventLoggerRails
  ##
  # Processes events, sending data to logger.
  class Emitter
    def initialize(logdev:)
      @logger = JsonLogger.new(logdev)
    end

    def log(event, level, data = {})
      Event.new(event).validate! do |validated_event|
        message = EventMessage.new(event: validated_event, data:)
        log_message(message, level)
      end
    rescue EventLoggerRails::Exceptions::UnregisteredEvent,
           EventLoggerRails::Exceptions::InvalidLoggerLevel => error
      log(error.event, :error, { message: error.message })
    end

    private

    attr_reader :logger

    def log_message(message, level)
      logger.send(level) { message }
    rescue NoMethodError
      raise EventLoggerRails::Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end
  end
end
