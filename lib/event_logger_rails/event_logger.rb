# frozen_string_literal: true

module EventLoggerRails
  # Writes log entries in configured format.
  class EventLogger < ::Logger
    include ActiveSupport::LoggerSilence

    # Initializes the logger with a JSON formatter.
    #
    # @param logdev [IO, #write] The log device for log output.
    def initialize(...)
      super(...)
      @formatter = EventLoggerRails.formatter.constantize.new || EventLoggerRails::Formatters::JSON.new
    end
  end
end
