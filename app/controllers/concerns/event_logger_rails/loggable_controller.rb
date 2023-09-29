# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant controller/request data.
  module LoggableController
    extend ActiveSupport::Concern
    include EventLoggerRails::Extensions::Loggable

    def optional_data
      {
        controller: controller_name.camelcase,
        action: action_name,
        method: request.method,
        path: request.path,
        remote_ip: request.remote_ip,
        parameters: request.parameters
      }
    end

    private :optional_data
  end
end
