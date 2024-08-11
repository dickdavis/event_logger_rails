# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2024-08-11

### Added

- Added support for using a custom logger class.
- Added support for using a custom formatter class.
- Added YARD documentation for project.

### Changed

- (Breaking) Renamed `EventLoggerRails::JsonLogger` to `EventLoggerRails::EventLogger`.
- (Breaking) Changed the name of the `optional_data` method in the `Loggable` concern to `optional_event_logger_data`

## [0.3.1] - 2023-10-14

### Added

- Added support for using `EventLoggerRails::JsonLogger` as a Rails logger replacement.

## [0.3.0] - 2023-10-05

### Added

- Added support for configurable log levels per event.
- Added support for specifying default log level.
- Added support for specifying log device.
- Added model concern for logging events in model layer.
- Added middleware to capture request details for logging.
- Added code quality tooling.

### Changed

- (Breaking) Changed interface for logging events.
- (Breaking) Changed config file structure.
- Changed default log device to be separate log file per environment.
- Refactored most of the application to make the engine more robust and maintainable.
- Switched test framework to RSpec.

### Fixed

- Fixed log output to output only in JSON (removed tags).

### Removed

- (Breaking) Removed support for versions of Ruby previous to `3.1.4`.
- (Breaking) Removed support for versions of Rails previous to `7`.

## [0.2.1] - 2021-12-27

### Fixed

- Fixed README instructions.

## [0.2.0] - 2021-12-27

### Added

- Added install generator.
- Added README instructions.

### Changed

- Changed the name of the configuration file.
- Improved registered event validation.

### Fixed

- Fixed exception handling in controller concern.
- Fixed config file reloading.

## [0.1.0] - 2021-12-24

### Added

- Initial release

[Unreleased]: https://github.com/d3d1rty/event_logger_rails/compare/0.4.0...HEAD
[0.4.0]: https://github.com/d3d1rty/event_logger_rails/compare/0.3.1...0.4.0
[0.3.1]: https://github.com/d3d1rty/event_logger_rails/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/d3d1rty/event_logger_rails/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/d3d1rty/event_logger_rails/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/d3d1rty/event_logger_rails/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/d3d1rty/event_logger_rails/releases/tag/0.1.0
