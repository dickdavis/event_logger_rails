# frozen_string_literal: true

module EventLoggerRails
  ##
  # Outputs event and related data logs.
  class EventLogger
    def initialize(logdev:, logger_class:)
      @logger = logger_class.new(logdev)
      @logger.formatter = proc do |level, timestamp, _progname, message|
        output = Output.new(level:, timestamp:, message:)
        "#{output.to_json}\n"
      end
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
