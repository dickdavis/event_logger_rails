# frozen_string_literal: true

config_file = File.read(Rails.root.join('config/event_logger_rails.yml'))
config_from_file = YAML.safe_load(config_file).deep_symbolize_keys

EventLoggerRails.setup do |config|
  config.registered_events = config_from_file[:registered_events]
end
