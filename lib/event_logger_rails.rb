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
  mattr_accessor :default_level
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
