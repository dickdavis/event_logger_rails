# frozen_string_literal: true

require_relative '../current_request'

module EventLoggerRails
  module Middleware
    ##
    # Middleware to capture request details and store in global state
    class CaptureRequestDetails
      def initialize(app)
        @app = app
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def call(env)
        begin
          request = ActionDispatch::Request.new(env)

          EventLoggerRails::CurrentRequest.id = env['action_dispatch.request_id']
          EventLoggerRails::CurrentRequest.format = request.headers['Content-Type']
          EventLoggerRails::CurrentRequest.method = request.method
          EventLoggerRails::CurrentRequest.parameters = request.parameters.except(:controller, :action, :format)
          EventLoggerRails::CurrentRequest.path = request.path
          EventLoggerRails::CurrentRequest.remote_ip = request.remote_ip

          status, headers, body = @app.call(env)
        ensure
          EventLoggerRails::CurrentRequest.reset
        end

        [status, headers, body]
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
