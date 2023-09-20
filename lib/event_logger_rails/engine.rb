# frozen_string_literal: true

module EventLoggerRails
  class Engine < ::Rails::Engine
    isolate_namespace EventLoggerRails

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
