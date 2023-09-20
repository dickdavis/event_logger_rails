# frozen_string_literal: true

require_relative 'lib/event_logger_rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'event_logger_rails'
  spec.version     = EventLoggerRails::VERSION
  spec.authors     = ['Dick Davis']
  spec.email       = ['dick@hey.com']
  spec.homepage    = 'https://github.com/d3d1rty/event_logger_rails'
  spec.summary     = 'Rails gem that facilitates logging events for analysis.'
  spec.description = 'Rails gem that facilitates logging events for analysis.'
  spec.license     = 'MIT'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/d3d1rty/event_logger_rails',
    'changelog_uri' => 'https://github.com/d3d1rty/event_logger_rails/blob/main/CHANGELOG.md'
  }

  spec.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 3.1.4'
  spec.add_dependency 'rails', '>= 7.0.0'
end
