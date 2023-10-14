# frozen_string_literal: true

module EventLoggerRails
  ##
  # Writes log entries in JSON format
  class JsonLogger < ::Logger
    include ActiveSupport::LoggerSilence

    def initialize(...)
      super(...)
      @formatter = proc do |level, timestamp, _progname, message|
        output = Output.new(level:, timestamp:, message:)
        "#{output.to_json}\n"
      end
    end
  end
end
