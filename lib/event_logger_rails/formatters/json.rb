# frozen_string_literal: true

module EventLoggerRails
  module Formatters
    # Writes log entries in JSON format
    class JSON < ActiveSupport::Logger::SimpleFormatter
      # Returns the formatted output for logging.
      #
      # @param level [Symbol] The level of the event.
      # @param timestamp [Time] The timestamp of the event.
      # @param progname [String] The name of the logger.
      # @param message [EventLoggerRails::Message, Hash, String] The message containing the data for logging.
      # @return [String] The formatted output for logging.
      def call(level, timestamp, _progname, message)
        output = Output.new(level:, timestamp:, message:)
        "#{output.to_json}\n"
      end
    end
  end
end
