# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require_relative '../app'
require_relative '../lib/config'

RSpec.describe RateLimiter::Middleware do
  include Rack::Test::Methods

  let(:app) { API.new } # API includes the middleware

  before(:all) do
    # Ensure a clean Redis state for tests
    cfg = Config.load
    redis = Redis.new(url: cfg[:redis_url])
    redis.flushdb
  end

  it 'allows requests under the limit' do
    5.times do
      get '/status'
      expect(last_response.status).to eq(200)
    end
  end

  it 'blocks requests exceeding the limit' do
    limit = Config.load[:rate_limit]

    limit.times { get '/data' }
    get '/data' # one extra request

    expect(last_response.status).to eq(429)
    body = JSON.parse(last_response.body)
    expect(body['error']).to eq('Rate limit exceeded. Try again later.')
  end

  it 'resets the counter after the window' do
    window = Config.load[:rate_window]

    # Exhaust the limit
    Config.load[:rate_limit].times { get '/' }

    # Should be blocked now
    get '/'
    expect(last_response.status).to eq(429)

    # Wait for the window to expire
    sleep(window + 1)

    # Counter should have reset
    get '/'
    expect(last_response.status).to eq(200)
  end
end