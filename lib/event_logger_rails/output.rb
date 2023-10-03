# frozen_string_literal: true

module EventLoggerRails
  ##
  # Merges data from application, request, and logger message for structured output
  class Output
    def initialize(level:, timestamp:, message:)
      @current_request = EventLoggerRails::CurrentRequest
      @level = level
      @timestamp = timestamp.iso8601(3)
      @message = message.respond_to?(:to_hash) ? sanitizer.filter(**message) : { message: }
    end

    def to_json(*args)
      JSON.generate(to_hash, *args)
    end

    def to_hash
      application_data.merge(**current_request_data, **logger_data)
    end

    private

    attr_reader :level, :timestamp, :message, :current_request

    def sanitizer
      @sanitizer ||= ActiveSupport::ParameterFilter.new(EventLoggerRails.sensitive_fields)
    end

    def application_data
      {
        environment: Rails.env,
        host: Socket.gethostname,
        service_name: Rails.application.class.module_parent_name
      }
    end

    # rubocop:disable Metrics/AbcSize
    def current_request_data
      return {} if CurrentRequest.instance.attributes.blank?

      {
        format: current_request.format,
        id: current_request.id,
        method: current_request.method,
        parameters: sanitizer.filter(current_request.parameters),
        path: current_request.path,
        remote_ip: current_request.remote_ip
      }
    end
    # rubocop:enable Metrics/AbcSize

    def logger_data
      {
        level:,
        timestamp:,
        **message
      }
    end
  end
end
