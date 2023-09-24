# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant controller/request data.
  module Loggable
    extend ActiveSupport::Concern

    def log_event(event, level = :warn, **data)
      EventLoggerRails.log(event, level, **data_from_request.merge(data))
    end

    private

    def data_from_request
      {
        controller: controller_name.camelcase,
        action: action_name,
        method: request.method,
        path: request.path,
        remote_ip: request.remote_ip,
        parameters: request.query_parameters.to_json
      }
    end
  end
end
