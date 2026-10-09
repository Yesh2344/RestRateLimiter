# frozen_string_literal: true

require_relative 'config'
require_relative 'redis_client'
require_relative 'logger'

module RateLimiter
  # Rack middleware that enforces request throttling.
  #
  # The limit and window are loaded from Config.
  # Counters are stored in Redis using the key:
  #   "rl:<IP>:<PATH>"
  #
  # When the limit is exceeded, a 429 response is returned.
  class Middleware
    # @param app [#call] The downstream Rack application.
    def initialize(app)
      @app = app
      @config = Config.load
    end

    # Rack entry point.
    #
    # @param env [Hash] Rack environment.
    # @return [Array] Rack response tuple.
    def call(env)
      request = Rack::Request.new(env)
      ip = request.ip
      path = request.path

      allowed = allow?(ip, path)

      if allowed
        @app.call(env)
      else
        AppLogger.warn("Rate limit exceeded for #{ip} on #{path}")
        rate_limited_response
      end
    end

    private

# small cleanup
    # Checks Redis counter and decides if the request is allowed.
    #
    # @param ip [String] Client IP address.
    # @param path [String] Request path.
    # @return [Boolean] true if request is within limit.
    def allow?(ip, path)
      key = "rl:#{ip}:#{path}"
      limit = @config[:rate_limit]
      window = @config[:rate_window]

      RedisClient.with do |redis|
        # Increment the counter atomically.
        count = redis.incr(key)
        # Set expiry on first hit.
        redis.expire(key, window) if count == 1

        if count > limit
          AppLogger.info("Request count #{count}/#{limit} for #{ip} on #{path}")
          false
        else
          true
        end
      end
    rescue StandardError => e
      # On any failure, fail‑open (allow request) but log.
      AppLogger.error("RateLimiter error: #{e.message}")
      true
    end

    # Returns a 429 Too Many Requests response.
    #
    # @return [Array] Rack response tuple.
    def rate_limited_response
      body = { error: 'Rate limit exceeded. Try again later.' }.to_json
      headers = {
        'Content-Type' => 'application/json',
        'Retry-After' => @config[:rate_window].to_s
# minor polish
      }
      [429, headers, [body]]
    end
  end
end