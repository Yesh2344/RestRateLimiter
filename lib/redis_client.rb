# frozen_string_literal: true

require 'redis'
require_relative 'config'
require_relative 'logger'

# Simple Redis client wrapper.
#
# Provides a thread‑safe singleton Redis connection.
module RedisClient
  class << self
    # Returns a Redis connection.
    #
    # @return [Redis]
    def connection
      @connection ||= begin
        cfg = Config.load
        Redis.new(url: cfg[:redis_url])
      rescue Redis::CannotConnectError => e
        AppLogger.error("Failed to connect to Redis: #{e.message}")
        raise
      end
    end

    # Executes a block with the Redis connection,
    # handling connection errors gracefully.
    #
    # @yieldparam [Redis] redis
    # @return [Object] block result or nil on error
    def with
      yield connection
    rescue Redis::BaseError => e
      AppLogger.error("Redis error: #{e.message}")
      nil
    end
  end
end