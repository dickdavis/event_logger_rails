# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant controller/request data.
  module LoggableController
    extend ActiveSupport::Concern
    include EventLoggerRails::Extensions::Loggable

    def optional_data
      {
        action: action_name,
        controller: controller_name.camelcase,
        format: request.headers['Content-Type'],
        method: request.method,
        parameters: request.parameters.except(%i[controller action format]),
        path: request.path,
        remote_ip: request.remote_ip
      }
    end

    private :optional_data
  end
end
