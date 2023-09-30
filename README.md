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
      log_event 'user.signup.failure', data: { errors: user.errors.full_messages  }
      render :new
    end
  end
end
```

In this example, a possible successful signup could be structured like this:

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "Kutima",
  "level": "WARN",
  "timestamp": "2023-09-29T23:23:16.633+00:00",
  "event_identifier": "user.signup.success",
  "event_description": "Indicates a user signup was successful.",
  "email": "testtesttest@test.com",
  "action": "create",
  "controller": "Registrations",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "testtesttest@test.com",
      "password": "[FILTERED]"
    }
  },
  "path": "/users",
  "remote_ip": "172.20.0.1"
}
```

...while a failed signup might look like this:

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "DummyApp",
  "level": "WARN",
  "timestamp": "2023-09-29T23:01:17.554+00:00",
  "event_identifier": "user.signup.failure",
  "event_description": "Indicates a user signup was not successful.",
  "errors": [
    "Email can't be blank",
    "Password can't be blank"
  ],
  "action": "create",
  "controller": "Registrations",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    },
  },
  "path": "/users",
  "remote_ip": "172.20.0.1"
}
```

Note how the log entry from the previous example contains the data passed in via the optional `data` argument.

You can also provide a logger level as an optional argument if you need to specify a logger level other than the default:

```ruby
log_event 'user.signup.failure', level: :error, data: { errors: user.errors }
```

This will output an event with the corresponding severity level. You must provide a valid logger level (`:debug, :info, :warn, :error, or :unknown`).

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "DummyApp",
  "level": "ERROR",
  "timestamp": "2023-09-29T23:01:17.554+00:00",
  "event_identifier": "user.signup.failure",
  "event_description": "Indicates a user signup was not successful.",
  "errors": [
    "Email can't be blank",
    "Password can't be blank"
  ],
  "action": "create",
  "controller": "Registrations",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    },
  },
  "path": "/users",
  "remote_ip": "172.20.0.1"
}
```

### Logging in Models

You can also log events from within models by including the `EventLoggerRails::LoggableModel` concern and calling `log_event`.

```ruby
class User < ApplicationRecord
  include EventLoggerRails::LoggableModel

  after_create :log_signup

  private

  def log_signup
    log_event 'user.signup.success', data: { email: }
  end
end
```

By default, `event_logger_rails` will include the model name and instance ID, along with whatever data is passed.

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "DummyApp",
  "level": "WARN",
  "timestamp": "2023-09-30T00:51:51.315+00:00",
  "event_identifier": "user.signup.success",
  "event_description": "Indicates a user signup was successful.",
  "email": "test_user_42@example.com",
  "model": "User",
  "instance_id": 38
}
```

### Logging Everywhere Else

You can log events from anywhere inside of your application by calling `EventLoggerRails.log` directly, though you won't get the additional context
from the request.

```ruby
EventLoggerRails.log 'user.signup.success', :info, { user_id: @user.id }
```

### Errors

There are two expected errors which are handled by `EventLoggerRails`: an unregistered event and an invalid logger level. Both will result
in a log entry with an event corresponding to the error, and the severity level will be set to `ERROR`.

If you fail to register an event, the logger will emit an `event_logger_rails.event.unregistered` event:

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "DummyApp",
  "level": "ERROR",
  "timestamp": "2023-09-29T23:27:53.714+00:00",
  "event_identifier": "event_logger_rails.event.unregistered",
  "event_description": "Indicates provided event was unregistered.",
  "message": "Event provided not registered: foo.bar"
}
```

If you provide an invalid log level, the logger will emit an `event_logger_rails.logger_level.invalid` event:

```json
{
  "host": "d6aeb6b0516c",
  "environment": "development",
  "service_name": "DummyApp",
  "level": "ERROR",
  "timestamp": "2023-09-29T23:30:29.761+00:00",
  "event_identifier": "event_logger_rails.logger_level.invalid",
  "event_description": "Indicates provided level was invalid.",
  "message": "Invalid logger level provided: 'foobar'. Valid levels: :debug, :info, :warn, :error, :unknown."
}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event_logger_rails'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install event_logger_rails
```

Run the install generator to create a config file (`config/event_logger_rails.yml`):

```bash
bin/rails generate event_logger_rails:install
```

Add your events to the generated config file following the structure of the examples.

By default, `event_logger_rails` outputs to a separate log file (`log/event_logger_rails.#{Rails.env}.log`) from normal Rails log output, allowing
you to ingest these logs independently. If you wish to set an alternative log device to capture output , you can configure it in `config/application.rb`:

```ruby
Rails.application.configure do |config|
  config.event_logger_rails.logdev = 'path/to/log.file'
end
```

## Contributing

Contributions are welcome. Feel free to open a PR.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

