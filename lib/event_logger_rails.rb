# frozen_string_literal: true

require 'rails'
require 'active_support/dependencies'
require 'event_logger_rails/engine'
require 'event_logger_rails/current_request'
require 'event_logger_rails/event'
require 'event_logger_rails/emitter'
require 'event_logger_rails/exceptions/invalid_logger_level'
require 'event_logger_rails/exceptions/unregistered_event'
require 'event_logger_rails/extensions/loggable'
require 'event_logger_rails/json_logger'
require 'event_logger_rails/message'
require 'event_logger_rails/middleware/capture_request_details'
require 'event_logger_rails/output'
require 'event_logger_rails/version'

##
# Namespace for EventLoggerRails gem
module EventLoggerRails
  autoload :CaptureRequestDetails, 'event_logger_rails/middleware/capture_request_details'
  autoload :CurrentRequest, 'event_logger_rails/current_request'
  autoload :Emitter, 'event_logger_rails/emitter'
  autoload :Event, 'event_logger_rails/event'
  autoload :InvalidLoggerLevel, 'event_logger_rails/exceptions/invalid_logger_level'
  autoload :JsonLogger, 'event_logger_rails/json_logger'
  autoload :Message, 'event_logger_rails/message'
  autoload :Output, 'event_logger_rails/output'
  autoload :UnregisteredEvent, 'event_logger_rails/exceptions/unregistered_event'

  mattr_accessor :logdev
  mattr_accessor :registered_events
  mattr_accessor :sensitive_fields

  def self.setup
    yield self
  end

  def self.emitter
    @emitter ||= Emitter.new(logdev:)
  end

  def self.log(...)
    emitter.log(...)
  end

  def self.reset
    @emitter = nil
  end
end
