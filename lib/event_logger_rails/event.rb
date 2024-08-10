# frozen_string_literal: true

module EventLoggerRails
  # Models an event for logging.
  class Event
    # Contains the default event registration.
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

    # @!attribute [r] identifier
    #   @return [String] The identifier of the event.
    attr_reader :identifier

    # @!attribute [r] description
    #   @return [String] The description of the event.
    attr_reader :description

    # @!attribute [r] level
    #   @return [Symbol] The configured logging level of the event.
    attr_reader :level

    # Initializes the event using the provided identifier to determine its properties from
    # either the default registration (for default events) or the user-defined registry.
    #
    # @param provided_identifier [EventLoggerRails::Event, String] The event or its identifier.
    def initialize(provided_identifier)
      @provided_identifier = provided_identifier.to_s

      # Attempt to find default registration for event
      if (default_event = DEFAULT_EVENTS[@provided_identifier])
        default_registration = [@provided_identifier, *default_event&.values]
      end

      # Fallback to user-defined registration if default not found.
      # Deconstruct registration to set identifier, description, and level attributes.
      @identifier, @description, @level = default_registration || config_registration
    end

    # Converts the event into a hash and merges the given hash into it.
    #
    # @param kwargs [Hash] The hash to merge into the event.
    # @return [Hash] The merged hash.
    # @example
    #   event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   event.merge(foo: 'bar')
    #   # {
    #   #   event_identifier: 'event_logger_rails.event.testing',
    #   #   event_description: 'Event reserved for testing',
    #   #   foo: 'bar'
    #   # }
    def merge(...)
      to_hash.merge(...)
    end

    # Determines if the event is valid.
    #
    # @return [Boolean] true if the event is valid, false otherwise.
    # @example
    #   valid_event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   valid_event.valid? # => true
    #   invalid_event = EventLoggerRails::Event.new('foo.bar.baz')
    #   invalid_event.valid? # => false
    def valid?
      identifier.present?
    end

    # Validates the event and yields it to the given block.
    #
    # @note This only validates the event registration. Logger level is validated at the time of logging.
    # @yield [self] Yields the event to the given block.
    # @raise [EventLoggerRails::Exceptions::UnregisteredEvent] If the event is not registered.
    # @example
    #   event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   event.validate! do |validated_event|
    #     puts "Event: #{validated_event}"
    #   end
    def validate!
      raise Exceptions::UnregisteredEvent.new(unregistered_event: self) unless valid?

      yield(self)
    end

    # Returns a hash representation of the event.
    #
    # @return [Hash] The event as a hash.
    # @example
    #   event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   event.to_hash
    #   # {
    #   #   event_identifier: 'event_logger_rails.event.testing',
    #   #   event_description: 'Event reserved for testing'
    #   # }
    def to_hash
      {
        event_identifier: identifier,
        event_description: description
      }
    end

    # Returns a string representation of the event.
    # The provided identifier is returned if the event is not registered.
    #
    # @return [String] The event as a string.
    # @example
    #   event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   event.to_s # => 'event_logger_rails.event.testing'
    def to_s
      identifier&.to_s || provided_identifier.to_s
    end

    # Determines if the event is equivalent to the given object through string comparison.
    #
    # @param other [EventLoggerRails::Event] The event to compare.
    # @return [Boolean] true if the event is equal to the given object, false otherwise.
    # @example
    #   event = EventLoggerRails::Event.new('event_logger_rails.event.testing')
    #   event == 'event_logger_rails.event.testing' # => true
    def ==(other)
      to_s == other.to_s
    end

    private

    # @!attribute [r] provided_identifier
    #   @return [String] The identifier provided when the event was initialized.
    attr_reader :provided_identifier

    # Parses the event identifier and looks up the details from the user-defined registry.
    #
    # @return [Array<String, String, Symbol>] The identifier, description, and level of the event.
    #   If the event is not registered, each array element will be nil.
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
