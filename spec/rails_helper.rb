# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'

Dir[EventLoggerRails::Engine.root.join('app/**/*.rb')].each { |file| require file  }
Dir[EventLoggerRails::Engine.root.join('lib/**/*.rb')].each { |file| require file  }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
