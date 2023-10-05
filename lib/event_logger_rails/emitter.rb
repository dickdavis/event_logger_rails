# frozen_string_literal: true

module EventLoggerRails
  ##
  # Processes events, sending data to logger.
  class Emitter
    def initialize(logdev:)
      @logger = JsonLogger.new(logdev)
    end

    def log(event, level:, data: {})
      Event.new(event).validate! do |validated_event|
        message = Message.new(event: validated_event, data:)
        level = level || validated_event.level || EventLoggerRails.default_level
        log_message(message, level.to_sym)
      end
    rescue Exceptions::UnregisteredEvent, Exceptions::InvalidLoggerLevel => error
      log(error.event, level: :error, data: { message: error.message })
    end

    private

    attr_reader :logger

    def log_message(message, level)
      logger.send(level) { message }
    rescue NoMethodError
      raise Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end
  end
end
