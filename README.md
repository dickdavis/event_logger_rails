# EventLoggerRails

Rails gem that facilitates logging events for analysis.

## Usage

You can define a registry of events that your application emits via the config file (`config/event_logger_rails.yml`).
The events that you define are placed in the `registered_events` structure in the config file.

For example, to register a user signup event, first define the event as a registered event:

```yaml
registered_events:
  user:
    signup:
      success: 'Indicates a user signup was successful.'
      failure: 'Indicates a user signup was not successful.'
```

Then, from the controller action that processes user signup's, include the `Loggable` concern and use the `log_event` method to log details about the event:

```ruby
class UsersController < ApplicationController
  include EventLoggerRails::Loggable

  def create
    user = User.new(user_params)
    if user.save
      log_event :info, 'user.signup.success'
      redirect_to dashboard_path
    else
      log_event :error, 'user.signup.failure', errors: user.errors
      render :new
     end
  end
end
```

In this example, a possible successful signup could be structured like this:

```
[INFO | 2021-12-27T20:57:06+00:00 | user.signup.success] {"controller"=>"Users", "action"=>"create", "method"=>"POST", "path"=>"/users", "remote_ip"=>"::1", "parameters"=>"{ "user"=>{ "email"=>"validemail@example.com", "first_name"=>"Test", "last_name"=>"User" } }"}
```

...while a failed signup might look like this:

```
[ERROR | 2021-12-27T20:57:06+00:00 | user.signup.failure] {"controller"=>"Users", "action"=>"create", "method"=>"POST", "path"=>"/users", "remote_ip"=>"::1", "parameters"=>"{ "user"=>{ "first_name"=>"Test", "last_name"=>"User" } }", "errors"=>"{ "email"=>"is missing" }"}
```

If you fail to register an event, the logger will emit an `event_logger_rails.event.unregistered` event:

```
[ERROR | 2021-12-27T20:57:06+00:00 | event_logger_rails.event.unregistered] {"controller"=>"Users", "action"=>"create", "method"=>"POST", "path"=>"/users", "remote_ip"=>"::1", "parameters"=>"{ "user"=>{ "first_name"=>"Test", "last_name"=>"User" } }", "message"=>"Event provided not registered: user.signup.failure"}
```

If you provide an invalid log level, the logger will emit an `event_logger_rails.logger_level.invalid` event:

```
[ERROR | 2021-12-27T20:57:06+00:00 | event_logger_rails.logger_level.invalid] {"controller"=>"Users", "action"=>"create", "method"=>"POST", "path"=>"/users", "remote_ip"=>"::1", "parameters"=>"{ "user"=>{ "first_name"=>"Test", "last_name"=>"User" } }", "message"=>"Invalid logger level provided: 'foo'. Valid levels: debug, info, warn, error, fatal."}
```

The log entry indicates the logger level (useful for filtering results), the registered event, and more useful information from the controller and request.
This makes it simple use a tool like `awk` or another monitoring solution to parse the logs for emitted events, facilitating troubleshooting and analytics.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event_logger_rails'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install event_logger_rails
```

Run the install generator to create a config file (`config/event_logger_rails.yml`) and example initializer:

```bash
$ bin/rails generate event_logger_rails:install
```

Add your events to the generated config file following the structure of the examples.

You may opt to load in registered events in `config/application.rb` using the `config_for` helper provided by Rails.

```ruby
EventLoggerRails.setup do |config|
  config.registered_events = config_for[:registered_events]
end
```

Doing so eliminates the need for the generated initializer, so you should delete it if you choose to go this route.

## Contributing

Contributions are welcome. Feel free to open a PR.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
