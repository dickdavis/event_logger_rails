# frozen_string_literal: true

require_relative 'event'
require_relative 'level'
require_relative 'exceptions/invalid_logger_level'
require_relative 'exceptions/unregistered_event'

module EventLoggerRails
  ##
  # Outputs event and related data logs.
  class EventLogger
    def initialize
      output_device = Rails.env.test? ? File.open(File::NULL, 'w') : $stdout
      @logger = ActiveSupport::TaggedLogging.new(Logger.new(output_device))
    end

    # rubocop:disable Metrics/AbcSize
    def log(level, event, **params)
      event = event.is_a?(EventLoggerRails::Event) ? event : EventLoggerRails::Event.new(event)
      raise EventLoggerRails::Exceptions::UnregisteredEvent.new(unregistered_event: event) unless event.valid?

      level = level.is_a?(EventLoggerRails::Level) ? level : EventLoggerRails::Level.new(level)
      raise EventLoggerRails::Exceptions::InvalidLoggerLevel.new(logger_level: level) unless level.valid?

      logger.tagged("#{level.to_s.upcase} | #{DateTime.current} | #{event}") do
        logger.send(level.to_sym, **params.as_json)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :logger
  end
end
