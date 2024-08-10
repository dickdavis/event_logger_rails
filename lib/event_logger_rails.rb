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

# Provides configurable state and public API for EventLoggerRails.
# Also serves as the namespace for the gem.
module EventLoggerRails
  # @!attribute [r] default_level
  #   @return [Symbol] The default level of the events logged by EventLoggerRails.
  mattr_accessor :default_level

  # @!attribute [r] logdev
  #   @return [IO, #write] The log device used by EventLoggerRails.
  mattr_accessor :logdev

  # @!attribute [r] registered_events
  #   @return [Array<Hash>] The events registry defined in the config/event_logger_rails.yml file.
  mattr_accessor :registered_events

  # @!attribute [r] sensitive_fields
  #   @return [Array<Symbol>] The fields which may contain sensitive data that EventLoggerRails should filter.
  mattr_accessor :sensitive_fields

  # Provides a method for configuring EventLoggerRails.
  #
  # @yield [self] Gives the class itself to the block for configuration.
  # @example
  #   EventLoggerRails.setup do |config|
  #     config.default_level = :info
  #   end
  # @return [void]
  def self.setup
    yield self
  end

  # Returns or initializes the Emitter instance for EventLoggerRails.
  #
  # @note The emitter is initialized with the configured log device.
  # @return [Emitter] The Emitter instance used for logging events.
  def self.emitter
    @emitter ||= Emitter.new(logdev:)
  end

  # Forwards the arguments to the Emitter's log method.
  #
  # @example
  #   EventLoggerRails.log('foo.bar.baz', level: :info, data: { foo: 'bar' })
  # @param (see Emitter#log)
  # @return [void]
  def self.log(...)
    emitter.log(...)
  end

  # Resets the Emitter instance.
  #
  # @return [void]
  def self.reset
    @emitter = nil
  end
end
