# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    # Indicates invalid log level provided.
    class InvalidLoggerLevel < StandardError
      # @!attribute [r] event
      #   @return [EventLoggerRails::Event] The default invalid logging level event.
      attr_reader :event

      # Initializes the exception with the given logger level.
      def initialize(logger_level:)
        super
        @event = Event.new('event_logger_rails.logger_level.invalid')
        @logger_level = logger_level
      end

      # Provides an informative error message.
      #
      # @return [String] The error message.
      def message
        "Invalid logger level provided: '#{logger_level.to_sym}'. " \
          'Valid levels: :debug, :info, :warn, :error, :unknown.'
      end

      private

      # @!attribute [r] logger_level
      #   @return [Symbol] The invalid logger level.
      attr_reader :logger_level
    end
  end
end
