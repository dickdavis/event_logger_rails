# frozen_string_literal: true

module EventLoggerRails
  # Processes events, sending data to logger.
  class Emitter
    # Initializes the emitter.
    # It references the configured log device for log output.
    # It references the configured logger class for logging, falling back to EventLogger.
    def initialize
      logdev = EventLoggerRails.logdev
      @logger = EventLoggerRails.logger_class.constantize.new(logdev) || EventLoggerRails::EventLogger.new(logdev)
    end

    # Validates and logs an event with the given level and data.
    # If an error is raised, it recursively calls itself with the error's event.
    #
    # @note Prefer to use the public API provided by `EventLoggerRails.log()`.
    # @param event [EventLoggerRails::Event, String] The event to log. Can be a string or an Event object.
    # @param level [Symbol] The level of the event.
    # @param data [Hash] Additional data to log.
    # @return [Integer] The number of bytes written to the log.
    # @example
    #   emitter = EventLoggerRails::Emitter.new
    #   emitter.log('foo.bar.baz', level: :info, data: { foo: 'bar' })
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

    # @!attribute [r] logger
    #   @return [JsonLogger] The logger instance used for log output.
    attr_reader :logger

    # Logs a message with the given level.
    #
    # @param message [String] The message to log.
    # @param level [Symbol] The level of the message.
    # @return [Integer] The number of bytes written to the log.
    # @raise [EventLoggerRails::Exceptions::InvalidLoggerLevel] If the level is invalid.
    def log_message(message, level)
      logger.send(level) { message }
    rescue NoMethodError
      raise Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end
  end
end
