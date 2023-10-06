# frozen_string_literal: true

require_relative 'lib/event_logger_rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'event_logger_rails'
  spec.version     = EventLoggerRails::VERSION
  spec.authors     = ['Dick Davis']
  spec.email       = ['dick@hey.com']
  spec.homepage    = 'https://github.com/dickdavis/event_logger_rails'
  spec.license     = 'MIT'
  spec.summary     = 'Rails gem weaving the fabric of logged events into tapestries for analytic reverie.'
  spec.description = <<~TEXT
    EventLoggerRails is a Rails engine for emitting structured events in logs during the execution of business processes for analysis and visualization.
    It allows teams to define events in a simple, centralized configuration file, and then log those events in JSON format for further processing.
  TEXT

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/dickdavis/event_logger_rails/tree/0.3.0',
    'changelog_uri' => 'https://github.com/dickdavis/event_logger_rails/blob/0.3.0/CHANGELOG.md'
  }

  spec.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 3.1.4'
  spec.add_dependency 'rails', '>= 7.0.0'
end
