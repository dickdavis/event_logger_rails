# frozen_string_literal: true

require 'rails'
require 'active_support/dependencies'
require 'event_logger_rails/version'
require 'event_logger_rails/engine'
require 'event_logger_rails/event_logger'
require 'event_logger_rails/event'
require 'event_logger_rails/level'
require 'event_logger_rails/exceptions/invalid_logger_level'
require 'event_logger_rails/exceptions/unregistered_event'

##
# Namespace for EventLoggerRails gem
module EventLoggerRails
  autoload :EventLogger, 'event_logger_rails/event_logger'
  autoload :Event, 'event_logger_rails/event'
  autoload :Level, 'event_logger_rails/level'
  autoload :InvalidLoggerLevel, 'event_logger_rails/exceptions/invalid_logger_level'
  autoload :UnregisteredEvent, 'event_logger_rails/exceptions/unregistered_event'

  mattr_accessor :registered_events
  mattr_accessor :logger_levels

  def self.setup
    yield self
  end

  def self.logger
    @logger ||= EventLogger.new
  end

  def self.log(*tags, **params)
    logger.log(*tags, **params)
  end
end
