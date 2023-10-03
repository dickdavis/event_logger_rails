# frozen_string_literal: true

module EventLoggerRails
  ##
  # Models a message sent to the logger containing event and optional data
  class Message
    def initialize(event:, data: {})
      @event = event
      @data = data
    end

    def to_hash
      event.merge(data)
    end

    private

    attr_reader :event, :data
  end
end
