# frozen_string_literal: true

require 'logger'

# Central logger used throughout the project.
#
# Logs to STDOUT with a timestamp and severity.
module AppLogger
  class << self
    # Returns a configured Logger instance.
    #
    # @return [Logger]
    def instance
      @instance ||= Logger.new($stdout).tap do |log|
        log.progname = 'RestRateLimiter'
        log.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime.utc.iso8601}] #{severity.ljust(5)} #{progname}: #{msg}\n"
        end
        log.level = Logger::INFO
      end
    end

    # Delegates missing methods to the underlying Logger.
    def method_missing(name, *args, &block)
      instance.public_send(name, *args, &block)
    end

    def respond_to_missing?(name, include_private = false)
      instance.respond_to?(name) || super
    end
  end
end