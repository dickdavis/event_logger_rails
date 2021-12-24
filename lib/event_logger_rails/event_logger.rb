# frozen_string_literal: true

require 'yaml'

require_relative 'exceptions/invalid_logger_level'
require_relative 'exceptions/unregistered_event'

module EventLoggerRails
  ##
  # Outputs event and related data logs.
  class EventLogger
    def initialize
      @logger_levels = logger_levels_from_config
      @registered_events = registered_events_from_config
      @last_updated = File.ctime(config_file)
    end

    def log(*tags, **params)
      reload_config if config_changed?

      level, event = *tags
      validate_tags(level, event)
      logger = ActiveSupport::TaggedLogging.new(Logger.new(output_device))
      logger.tagged("#{level.to_s.upcase} | #{DateTime.current} | #{event}") { logger.send(level, **params.as_json) }
    end

    private

    attr_reader :logger_levels, :registered_events, :last_updated

    def logger_levels_from_config
      data_from_config[:logger_levels].map(&:to_sym)
    end

    def registered_events_from_config
      data_from_config[:registered_events]
    end

    def data_from_config
      @data_from_config ||= YAML.safe_load(File.read(config_file)).deep_symbolize_keys
    end

    def config_file
      Rails.root.join('config/event_logger.yml')
    end

    def reload_config
      @logger_levels = logger_levels_from_config
      @registered_events = registered_events_from_config
      @last_updated = File.ctime(config_file)
    end

    def config_changed?
      return false unless Rails.env.development?

      last_updated != File.ctime(config_file)
    end

    def validate_tags(level, event)
      validate_logger_level(level) && validate_event(event)
    end

    def validate_logger_level(level)
      return true if logger_levels.include?(level)

      raise EventLoggerRails::Exceptions::InvalidLoggerLevel.new(logger_level: level)
    end

    def validate_event(event)
      return true if registered_events.include?(event)

      raise EventLoggerRails::Exceptions::UnregisteredEvent.new(unregistered_event: event)
    end

    def output_device
      return $stdout unless Rails.env.test?

      File.open(File::NULL, 'w')
    end
  end
end
