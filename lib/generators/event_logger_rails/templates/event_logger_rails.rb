# frozen_string_literal: true

##
# This initializer demonstrates how registered events can be loaded from a configuration file.
# Alternatively, one can load them directly in `config/application.rb`, or another way preferable
# to the development team. Refer to the README for additional information.

# Read the configuration file.
config_file = File.read(Rails.root.join('config/event_logger_rails.yml'))

# Load in the YAML and symbolize the keys.
config_from_file = YAML.safe_load(config_file).deep_symbolize_keys

# Invoke the setup for EventLoggerRails and pass it a block to set configuration options.
EventLoggerRails.setup do |config|
  # Assign the registered events as part of the configuration.
  config.registered_events = config_from_file[:registered_events]
end
