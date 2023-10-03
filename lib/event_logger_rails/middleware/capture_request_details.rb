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

          CurrentRequest.id = env['action_dispatch.request_id']
          CurrentRequest.format = request.headers['Content-Type']
          CurrentRequest.method = request.method
          CurrentRequest.parameters = request.parameters.except(:controller, :action, :format)
          CurrentRequest.path = request.path
          CurrentRequest.remote_ip = request.remote_ip

          status, headers, body = @app.call(env)
        ensure
          CurrentRequest.reset
        end

        [status, headers, body]
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
