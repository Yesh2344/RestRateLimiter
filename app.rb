# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require_relative 'lib/config'
require_relative 'lib/logger'
require_relative 'lib/redis_client'
require_relative 'lib/rate_limiter'

require 'sinatra/base'
require 'json'

# Simple Sinatra API demonstrating the RateLimiter middleware.
class API < Sinatra::Base
  use RateLimiter::Middleware

  before do
    content_type :json
  end

  get '/' do
    { message: 'Welcome to RestRateLimiter API' }.to_json
  end

  get '/status' do
    { status: 'ok', timestamp: Time.now.utc }.to_json
  end

  # Simulated heavy endpoint
  get '/data' do
    # In a real app this could be a DB call, etc.
    { data: Array.new(5) { rand(1000) } }.to_json
  end

  # Global error handler to return JSON errors
  error do
    e = env['sinatra.error']
    AppLogger.error("Unhandled exception: #{e.class} - #{e.message}")
    status 500
    { error: 'Internal server error' }.to_json
  end

  run! if app_file == $PROGRAM_NAME
end