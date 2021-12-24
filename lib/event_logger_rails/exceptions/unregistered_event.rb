# frozen_string_literal: true

module EventLoggerRails
  module Exceptions
    ##
    # Indicates event provided not registered.
    class UnregisteredEvent < StandardError
      attr_reader :unregistered_event

      def initialize(unregistered_event:)
        super("Event provided not registered: #{unregistered_event}")
      end
    end
  end
end
