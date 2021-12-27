# frozen_string_literal: true

module EventLoggerRails
  module Generators
    ##
    # Creates basic config file for EventLoggerRails
    class InstallGenerator < Rails::Generators::Base
      desc 'Create basic config file for EventLoggerRails'
      source_root File.expand_path('templates', __dir__)

      def copy_config_file
        copy_file 'event_logger_rails.yml', 'config/event_logger_rails.yml'
      end
    end
  end
end
