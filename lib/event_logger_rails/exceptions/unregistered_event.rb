# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    ##
    # Indicates event provided not registered.
    class UnregisteredEvent < StandardError
      attr_reader :event

      def initialize(unregistered_event:)
        super()
        @event = Event.new('event_logger_rails.event.unregistered')
        @unregistered_event = unregistered_event
      end

      def message
        "Event provided not registered: #{unregistered_event}"
      end

      private

      attr_reader :unregistered_event
    end
  end
end
