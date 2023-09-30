# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides global state with request details
  class CurrentRequest < ActiveSupport::CurrentAttributes
    attribute :id, :format, :method, :parameters, :path, :remote_ip
  end
end
