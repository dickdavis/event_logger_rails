# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant controller/request data.
  module LoggableController
    extend ActiveSupport::Concern
    include EventLoggerRails::Extensions::Loggable

    # Includes the controller name and action in the log output.
    #
    # @return [Hash] The data to include in log output.
    def optional_data
      {
        action: action_name,
        controller: controller_name.camelcase
      }
    end

    private :optional_data
  end
end
