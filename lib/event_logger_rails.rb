# frozen_string_literal: true

require 'rails'
require 'active_support/dependencies'
require 'event_logger_rails/engine'
require 'event_logger_rails/current_request'
require 'event_logger_rails/event'
require 'event_logger_rails/event_logger'
require 'event_logger_rails/event_message'
require 'event_logger_rails/exceptions/invalid_logger_level'
require 'event_logger_rails/exceptions/unregistered_event'
require 'event_logger_rails/extensions/loggable'
require 'event_logger_rails/middleware/capture_request_details'
require 'event_logger_rails/version'

##
# Namespace for EventLoggerRails gem
module EventLoggerRails
  autoload :CaptureRequestDetails, 'event_logger_rails/middleware/capture_request_details'
  autoload :CurrentRequest, 'event_logger_rails/current_request'
  autoload :Event, 'event_logger_rails/event'
  autoload :EventLogger, 'event_logger_rails/event_logger'
  autoload :InvalidLoggerLevel, 'event_logger_rails/exceptions/invalid_logger_level'
  autoload :JsonLogger, 'event_logger_rails/json_logger'
  autoload :Output, 'event_logger_rails/output'
  autoload :UnregisteredEvent, 'event_logger_rails/exceptions/unregistered_event'

  mattr_accessor :logdev
  mattr_accessor :logger_class
  mattr_accessor :registered_events
  mattr_accessor :sensitive_fields

  def self.setup
    yield self
  end

  def self.event_logger
    @event_logger ||= EventLogger.new(logdev:, logger_class:)
  end

  def self.log(...)
    event_logger.log(...)
  end

  def self.reset
    @event_logger = nil
  end
end
