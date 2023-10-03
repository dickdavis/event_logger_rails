# frozen_string_literal: true

module EventLoggerRails
  ##
  # Models an event for logging.
  class Event
    DEFAULT_EVENTS = {
      'event_logger_rails.logger_level.invalid' => 'Indicates provided level was invalid.',
      'event_logger_rails.event.unregistered' => 'Indicates provided event was unregistered.',
      'event_logger_rails.event.testing' => 'Event reserved for testing.'
    }.freeze
    private_constant :DEFAULT_EVENTS

    attr_reader :identifier, :description

    def initialize(provided_identifier)
      @provided_identifier = provided_identifier.to_s

      default_registration = DEFAULT_EVENTS.slice(@provided_identifier).to_a.flatten
      @identifier, @description = if default_registration.empty?
                                    config_registration
                                  else
                                    default_registration
                                  end
    end

    def merge(...)
      to_hash.merge(...)
    end

    def valid?
      identifier.present?
    end

    def validate!
      raise EventLoggerRails::Exceptions::UnregisteredEvent.new(unregistered_event: self) unless valid?

      yield(self)
    end

    def to_hash
      {
        event_identifier: identifier,
        event_description: description
      }
    end

    def to_s
      identifier&.to_s || provided_identifier.to_s
    end

    def ==(other)
      to_s == other.to_s
    end

    private

    attr_reader :provided_identifier

    def config_registration
      parsed_event = provided_identifier.split('.').map(&:to_sym)
      if (description = EventLoggerRails.registered_events.dig(*parsed_event))
        [provided_identifier, description]
      else
        [nil, nil]
      end
    end
  end
end
