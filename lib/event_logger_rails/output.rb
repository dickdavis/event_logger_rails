# frozen_string_literal: true

module EventLoggerRails
  # Merges data from application, request, and logger message for structured output
  class Output
    # Initializes the output with the given level, timestamp, and message.
    #
    # @param level [Symbol] The level of the event.
    # @param timestamp [Time] The timestamp of the event.
    # @param message [EventLoggerRails::Message] The message of the event.
    def initialize(level:, timestamp:, message:)
      @current_request = EventLoggerRails::CurrentRequest
      @level = level
      @timestamp = timestamp.iso8601(3)
      @message = message.respond_to?(:to_hash) ? sanitizer.filter(**message) : { message: }
    end

    # Converts the output to a JSON string.
    #
    # @return [String] The JSON representation of the output.
    def to_json(*args)
      JSON.generate(to_hash, *args)
    end

    # Converts the output to a hash containing the application, request, and logger details.
    #
    # @return [Hash] The hash representation of the output.
    def to_hash
      application_data.merge(**current_request_data, **logger_data)
    end

    private

    # @!attribute [r] level
    #   @return [Symbol] The level of the event.
    attr_reader :level

    # @!attribute [r] timestamp
    #   @return [Time] The timestamp of the event.
    attr_reader :timestamp

    # @!attribute [r] message
    #   @return [EventLoggerRails::Message] The message to log.
    attr_reader :message

    # @!attribute [r] current_request
    #   @return [EventLoggerRails::CurrentRequest] The object storing the current request data.
    attr_reader :current_request

    # Finds or initializes a parameter filter for sensitive data.
    #
    # @return [ActiveSupport::ParameterFilter] The parameter filter for sensitive data.
    def sanitizer
      @sanitizer ||= ActiveSupport::ParameterFilter.new(EventLoggerRails.sensitive_fields)
    end

    # Structures the application data to include in the output.
    #
    # @return [Hash] The application data to include in the output.
    def application_data
      {
        environment: Rails.env,
        host: Socket.gethostname,
        service_name: Rails.application.class.module_parent_name
      }
    end

    # rubocop:disable Metrics/AbcSize

    # Structures the request data to include in the output.
    #
    # @return [Hash] The request data to include in the output.
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

    # Structures the logger data to include in the output.
    #
    # @return [Hash] The logger data to include in the output.
    # @note The logger data includes the level, timestamp, and message.
    def logger_data
      {
        level:,
        timestamp:,
        **message
      }
    end
  end
end
