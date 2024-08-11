# frozen_string_literal: true

module EventLoggerRails
  module Extensions
    # Provides event logging with optional data.
    module Loggable
      # Logs an event with the given level and data.
      #
      # @param event [EventLoggerRails::Event] The event to log.
      # @option kwargs [Symbol] :level The level of the event.
      # @option kwargs [Hash] :data The data of the event.
      def log_event(event, **kwargs)
        EventLoggerRails.log(
          event,
          level: kwargs[:level] || nil,
          data: (kwargs[:data] || {}).merge(optional_event_logger_data)
        )
      end

      private

      # Optional data to include in log output.
      #
      # @return [Hash] The data to include in log output.
      # @note This method can be overridden by classes that implement Loggable.
      def optional_event_logger_data
        {}
      end
    end
  end
end
