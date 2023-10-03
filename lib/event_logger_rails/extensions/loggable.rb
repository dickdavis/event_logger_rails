# frozen_string_literal: true

module EventLoggerRails
  module Extensions
    ##
    # Provides event logging with relevant model data.
    module Loggable
      def log_event(event, level: :warn, data: {})
        EventLoggerRails.log(event, level, data.merge(optional_data))
      end

      private

      def optional_data
        {}
      end
    end
  end
end
