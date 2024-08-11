# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development do
  gem 'overcommit'
  gem 'redcarpet'
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'solargraph'
  gem 'solargraph-rails'
  gem 'sqlite3'
  gem 'yard'
end

group :test do
  gem 'rspec-rails'
  gem 'warning'
end

group :development, :test do
  gem 'debug'
end
