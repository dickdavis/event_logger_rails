# frozen_string_literal: true

module EventLoggerRails
  ##
  # Models a logger level
  class Level
    def initialize(level)
      @level = level
    end

    def valid?
      EventLoggerRails.logger_levels.include?(level)
    end

    def to_s
      level.to_s
    end

    def to_sym
      level.to_sym
    end

    private

    attr_reader :level
  end
end
