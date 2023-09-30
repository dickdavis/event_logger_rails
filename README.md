## 🔌 EventLoggerRails 💾

![Elrika in the Wired](elrika-in-the-wired.png?raw=true)

Are you tired of navigating through logs as if you're lost in the labyrinth of the Wired, searching for that elusive piece of data? Say "Hello, World!" to `EventLoggerRails`, the Rails engine transmuting your logs into cryptic gems of understanding. 💎

### Visualize This

In a single, centralized config file, decipher the events that pulse through the veins of your business. Once set, let `EventLoggerRails` weave them into intricate patterns of JSON logs that shimmer like a digital mirage. 🎇

### Yet, The Nexus Expands

Channel these JSON enigmas directly into analytic realms like OpenSearch. There, witness the alchemy of data taking form through real-time visualizations and analysis. 📊✨

### Why Choose `EventLoggerRails`?

- 🚀 **Fast Setup**: Get your logging up and running in minutes, not hours!
- 🌐 **Team-Friendly Event Registry**: Simplify how your team defines and logs business-critical events.
- 📚 **Readable**: Logs in a clean, JSON-formatted structure for easy parsing and analysis.
- 🔍 **In-Depth Insight**: Elevate your business process analysis with granular, structured logging.

Don't let crucial events get lost in the digital void. Make your app's logging as unforgettable as your first journey into the Wired with `EventLoggerRails`!

## Usage

You can define a registry of events your application emits via the config file (`config/event_logger_rails.yml`).
The events you define are placed in the `registered_events` structure in the config file.

For example, to register a user signup event, first define the event as a registered event:

```yaml
registered_events:
  user:
    signup:
      success: 'Indicates a user signup was successful.'
      failure: 'Indicates a user signup was not successful.'
```

### Logging in Controllers

Continuing this example, we'll want to log the events we registered. To do so, include the `EventLoggerRails::LoggableController` concern in the controller that
processes user signup's and call the `log_event` method to log details about the event:

```ruby
class UsersController < ApplicationController
  include EventLoggerRails::LoggableController

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
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "2b8f44c1-0e42-4a5f-84b8-52659990d138",
  "service_name": "DummyApp",
  "level": "WARN",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "princess@leia.com",
      "password": "[FILTERED]"
    }
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T06:47:16.938+00:00",
  "event_identifier": "user.signup.success",
  "event_description": "Indicates a user signup was successful.",
  "email": "princess@leia.com",
  "action": "create",
  "controller": "Registrations"
}
```

...while a failed signup might look like this:

```json
{
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "2b8f44c1-0e42-4a5f-84b8-52656690d138",
  "service_name": "DummyApp",
  "level": "WARN",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    },
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T06:47:16.928+00:00",
  "event_identifier": "user.signup.failure",
  "event_description": "Indicates a user signup was not successful.",
  "errors": [
    "Email can't be blank",
    "Password can't be blank"
  ],
  "email": "princess@leia.com",
  "action": "create",
  "controller": "Registrations"
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
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "2b8f44c1-0e42-4a5f-84b8-52656690d138",
  "service_name": "DummyApp",
  "level": "ERROR",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    },
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T06:47:16.928+00:00",
  "event_identifier": "user.signup.failure",
  "event_description": "Indicates a user signup was not successful.",
  "errors": [
    "Email can't be blank",
    "Password can't be blank"
  ],
  "email": "princess@leia.com",
  "action": "create",
  "controller": "Registrations"
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

By default, `EventLoggerRails` will include the model name, instance ID, and whatever data is passed.

```json
{
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "2b8f44c1-0e42-4a5f-84b8-52652332d138",
  "service_name": "DummyApp",
  "level": "WARN",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "princess@leia.com",
      "password": "[FILTERED]"
    }
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T06:47:16.817+00:00",
  "event_identifier": "user.signup.success",
  "event_description": "Indicates a user signup was successful.",
  "email": "princess@leia.com",
  "model": "User",
  "instance_id": 41
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
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "94c5ffe9-1bd8-4e04-88a3-478958e242b0",
  "service_name": "DummyApp",
  "level": "ERROR",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    }
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T07:03:34.993+00:00",
  "event_identifier": "event_logger_rails.event.unregistered",
  "event_description": "Indicates provided event was unregistered.",
  "message": "Event provided not registered: foo.bar"
}
```

If you provide an invalid log level, the logger will emit an `event_logger_rails.logger_level.invalid` event:

```json
{
  "environment": "development",
  "format": "application/x-www-form-urlencoded;charset=UTF-8",
  "host": "d6aeb6b0516c",
  "id": "11541423-0008-4cc7-aef7-1e4af9a801d7",
  "service_name": "DummyApp",
  "level": "ERROR",
  "method": "POST",
  "parameters": {
    "authenticity_token": "[FILTERED]",
    "user": {
      "email": "",
      "password": "[FILTERED]"
    }
  },
  "path": "/users",
  "remote_ip": "172.20.0.1",
  "timestamp": "2023-09-30T07:04:52.623+00:00",
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

By default, `EventLoggerRails` outputs to a separate log file (`log/event_logger_rails.#{Rails.env}.log`) from normal Rails log output, allowing
you to ingest these logs independently. If you wish to set an alternative log device to capture output, you can configure it in `config/application.rb`:

```ruby
Rails.application.configure do |config|
  config.event_logger_rails.logdev = 'path/to/log.file'
end
```

## Contributing

Your inputs echo in this realm. Venture forth and materialize your thoughts through a PR.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

