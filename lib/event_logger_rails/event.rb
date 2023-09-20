# frozen_string_literal: true

module EventLoggerRails
  ##
  # Models an event for logging.
  class Event
    DEFAULT_EVENTS = [
      'event_logger_rails.logger_level.invalid',
      'event_logger_rails.event.unregistered',
      'event_logger_rails.event.testing'
    ].freeze
    private_constant :DEFAULT_EVENTS

    def initialize(identifier)
      @identifier = identifier
    end

    def valid?
      event_registered? || default_event?
    end

    def to_s
      identifier.to_s
    end

    def ==(other)
      identifier.to_s == other.to_s
    end

    private

    attr_reader :identifier

    def event_registered?
      parsed_event = identifier.split('.').map(&:to_sym)
      EventLoggerRails.registered_events.dig(*parsed_event)
    end

    def default_event?
      DEFAULT_EVENTS.include?(identifier)
    end
  end
end
