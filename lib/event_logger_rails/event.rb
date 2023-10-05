# frozen_string_literal: true

module EventLoggerRails
  ##
  # Models an event for logging.
  class Event
    DEFAULT_EVENTS = {
      'event_logger_rails.logger_level.invalid' => {
        description: 'Indicates provided level was invalid.',
        level: :error
      },
      'event_logger_rails.event.unregistered' => {
        description: 'Indicates provided event was unregistered.',
        level: :error
      },
      'event_logger_rails.event.testing' => {
        description: 'Event reserved for testing.',
        level: :warn
      }
    }.freeze
    private_constant :DEFAULT_EVENTS

    attr_reader :identifier, :description, :level

    def initialize(provided_identifier)
      @provided_identifier = provided_identifier.to_s

      if (default_event = DEFAULT_EVENTS[@provided_identifier])
        default_registration = [@provided_identifier, *default_event&.values]
      end

      @identifier, @description, @level = default_registration || config_registration
    end

    def merge(...)
      to_hash.merge(...)
    end

    def valid?
      identifier.present?
    end

    def validate!
      raise Exceptions::UnregisteredEvent.new(unregistered_event: self) unless valid?

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
      config = EventLoggerRails.registered_events.dig(*parsed_event)
      case config
      in { description:, level: }
        [provided_identifier, description, level]
      in { description: }
        [provided_identifier, description, nil]
      else
        [nil, nil, nil]
      end
    end
  end
end
