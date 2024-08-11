# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant model data.
  module LoggableModel
    extend ActiveSupport::Concern
    include EventLoggerRails::Extensions::Loggable

    # Includes the model name and instance ID in the log output.
    #
    # @return [Hash] The data to include in log output.
    def optional_event_logger_data
      {
        model: self.class.name,
        instance_id: id
      }
    end

    private :optional_event_logger_data
  end
end
