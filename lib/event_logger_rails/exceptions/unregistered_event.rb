# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    # Indicates event provided not registered.
    class UnregisteredEvent < StandardError
      # @!attribute [r] event
      #   @return [EventLoggerRails::Event] The default event for unregistered events.
      attr_reader :event

      # Initializes the exception with the given unregistered event.
      #
      # @param unregistered_event [EventLoggerRails::Event] The unregistered event.
      def initialize(unregistered_event:)
        super()
        @event = Event.new('event_logger_rails.event.unregistered')
        @unregistered_event = unregistered_event
      end

      # Provides an informative error message.
      #
      # @return [String] The error message.
      def message
        "Event provided not registered: #{unregistered_event}"
      end

      private

      # @!attribute [r] unregistered_event
      #   @return [EventLoggerRails::Event] The unregistered event.
      attr_reader :unregistered_event
    end
  end
end
