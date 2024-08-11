# frozen_string_literal: true

module EventLoggerRails
  # Provides global state with request details
  class CurrentRequest < ActiveSupport::CurrentAttributes
    # @note Defines the attributes for the current request object.
    # @!attribute [rw] id
    #   @return [String] The ID of the request.
    # @!attribute [rw] format
    #   @return [Symbol] The format of the request.
    # @!attribute [rw] method
    #   @return [String] The HTTP method of the request.
    # @!attribute [rw] parameters
    #   @return [Hash] The parameters of the request.
    # @!attribute [rw] path
    #   @return [String] The path of the request.
    # @!attribute [rw] remote_ip
    #   @return [String] The remote IP of the request.
    attribute :id, :format, :method, :parameters, :path, :remote_ip
  end
end
