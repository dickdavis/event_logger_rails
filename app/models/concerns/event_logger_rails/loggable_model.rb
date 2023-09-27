# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant model data.
  module LoggableModel
    extend ActiveSupport::Concern
    include EventLoggerRails::Extensions::Loggable

    def optional_data
      {
        model: self.class.name,
        instance_id: id
      }
    end

    private :optional_data
  end
end
