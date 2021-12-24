# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    ##
    # Indicates invalid log level provided.
    class InvalidLoggerLevel < StandardError
      attr_reader :logger_level

      def initialize(logger_level:)
        super("Invalid logger level provided: '#{logger_level}'. Valid levels: debug, info, warn, error, fatal.")
      end
    end
  end
end
