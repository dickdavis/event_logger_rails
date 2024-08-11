# frozen_string_literal: true

module EventLoggerRails
  # Models a message sent to the logger containing event and optional data
  class Message
    # Initializes the message with the given event and data.
    #
    # @param event [EventLoggerRails::Event] The event to log.
    # @param data [Hash] Additional data to log.
    def initialize(event:, data: {})
      @event = event
      @data = data
    end

    # Converts the message to a hash containing the event and data details.
    #
    # @return [Hash] The hash representation of the message.
    def to_hash
      event.merge(data)
    end

    private

    # @!attribute [r] event
    #   @return [EventLoggerRails::Event] The event to log.
    attr_reader :event

    # @!attribute [r] data
    #   @return [Hash] Additional data to log.
    attr_reader :data
  end
end
