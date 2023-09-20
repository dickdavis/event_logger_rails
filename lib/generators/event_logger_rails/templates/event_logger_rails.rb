# frozen_string_literal: true

config_file = Rails.root.join('config/event_logger_rails.yml')
config_from_file = YAML.safe_load(File.read(config_file)).deep_symbolize_keys

EventLoggerRails.setup do |config|
  config.registered_events = config_from_file[:registered_events]
  config.logger_levels = config_from_file[:logger_levels].map(&:to_sym)
end
