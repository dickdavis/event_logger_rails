# frozen_string_literal: true

require 'rails/generators'

module EventLoggerRails
  module Generators
    ##
    # Creates basic config file and initializer for EventLoggerRails
    class InstallGenerator < Rails::Generators::Base
      desc 'Create event registry file'
      source_root File.expand_path('templates', __dir__)

      def copy_config_file
        return if File.exist?(File.join(destination_root, 'config/event_logger_rails.yml'))

        copy_file 'event_logger_rails.yml', 'config/event_logger_rails.yml'
      end
    end
  end
end
