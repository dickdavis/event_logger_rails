# frozen_string_literal: true

module EventLoggerRails
  ##
  # Engine for plugging into Rails
  class Engine < ::Rails::Engine
    isolate_namespace EventLoggerRails

    config.generators do |generator|
      generator.test_framework :rspec
    end
  end
end
