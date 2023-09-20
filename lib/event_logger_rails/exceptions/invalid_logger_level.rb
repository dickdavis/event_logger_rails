# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    ##
    # Indicates invalid log level provided.
    class InvalidLoggerLevel < StandardError
      attr_reader :event

      def initialize(logger_level:)
        super
        @event = EventLoggerRails::Event.new('event_logger_rails.logger_level.invalid')
        @logger_level = logger_level
      end

      def message
        "Invalid logger level provided: '#{logger_level.to_sym}'. " \
          "Valid levels: #{EventLoggerRails.logger_levels.map(&:inspect).join(', ')}."
      end

      private

      attr_reader :logger_level
    end
  end
end
