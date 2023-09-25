# EventLoggerRails

`EventLoggerRails` is a Rails engine for emitting structured events in logs during the execution of business processes for analysis and visualization.
It allows teams to define events in a simple, centralized configuration file, and then log those events in JSON format for further processing.

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

### Logging in Controllers

Continuing this example, we'll want to log the events we registered. To do so, include the `EventLoggerRails::Loggable` concern in the controller that
processes user signup's and call the `log_event` method to log details about the event:

```ruby
class UsersController < ApplicationController
  include EventLoggerRails::Loggable

  def create
    user = User.new(user_params)
    if user.save
      log_event 'user.signup.success'
      redirect_to dashboard_path
    else
      log_event 'user.signup.failure', errors: user.errors
      render :new
     end
  end
end
```

In this example, a possible successful signup could be structured like this:

```json
{
    "message": {
        "event_description": "Indicates a user signup was successful.",
        "event_identifier": "user.signup.success",
        "controller": "Users",
        "action": "create",
        "method": "POST",
        "path": "/users",
        "remote_ip": "::1",
        "parameters": {
            "user": {
                "first_name": "Test",
                "last_name": "User"
            }
        }
    },
    "severity": "WARN",
    "timestamp": "2023-09-23 22:27:33 -0500"
}
```

...while a failed signup might look like this:

```json
{
    "message": {
        "event_description": "Indicates a user signup was not successful.",
        "event_identifier": "user.signup.failure",
        "controller": "Users",
        "action": "create",
        "method": "POST",
        "path": "/users",
        "remote_ip": "::1",
        "parameters": {
            "user": {
                "first_name": "Test",
                "last_name": "User"
            }
        },
        "errors": {
            "email": "is missing"
        }
    },
    "severity": "WARN",
    "timestamp": "2023-09-23 22:27:33 -0500"
}
```

You can also provide a logger level as an optional argument if you need to specify a logger level other than the default:

```ruby
log_event 'user.signup.failure', :error, errors: user.errors
```

This will output an event with the corresponding severity level. You must provide a valid logger level (`:debug, :info, :warn, :error, or :unknown`).

```json
{
    "message": {
        "event_description": "Indicates a user signup was not successful.",
        "event_identifier": "user.signup.failure",
        "controller": "Users",
        "action": "create",
        "method": "POST",
        "path": "/users",
        "remote_ip": "::1",
        "parameters": {
            "user": {
                "first_name": "Test",
                "last_name": "User"
            }
        },
        "errors": {
            "email": "is missing"
        }
    },
    "severity": "ERROR",
    "timestamp": "2023-09-23 22:27:33 -0500"
}
```

### Logging Outside of Controllers

You can log events from anywhere inside of your application by calling `EventLoggerRails.log` directly, though you won't get the additional context
from the request.

```ruby
EventLoggerRails.log 'user.signup.success', :info, user_id: @user.id
```

### Errors

There are two expected errors which are handled by `EventLoggerRails`: an unregistered event and an invalid logger level. Both will result
in a log entry with an event corresponding to the error, and the severity level will be set to `ERROR`.

If you fail to register an event, the logger will emit an `event_logger_rails.event.unregistered` event:

```json
{
    "message": {
        "event_description": "event_logger_rails.event.unregistered",
        "event_identifier": "Indicates provided event was unregistered."
    },
    "severity": "ERROR",
    "timestamp": "2023-09-23 22:27:33 -0500"
}
```

If you provide an invalid log level, the logger will emit an `event_logger_rails.logger_level.invalid` event:

```json
{
    "message": {
        "event_description": "event_logger_rails.logger_level.invalid",
        "event_identifier": "Indicates provided level was invalid."
    },
    "severity": "ERROR",
    "timestamp": "2023-09-23 22:27:33 -0500"
}
```

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
