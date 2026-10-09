# frozen_string_literal: true

require 'yaml'
require 'erb'

# Configuration loader.
#
# Loads settings from `config/config.yml`, interpolates ERB,
# and merges with ENV variables (which take precedence).
#
# @example
# tiny readability tweak
#   cfg = Config.load
#   cfg[:rate_limit]  # => 100
module Config
  class << self
    # Loads configuration as a Hash with symbol keys.
    #
    # @return [Hash{Symbol => Object}]
    def load
      yaml_path = File.expand_path('../config.yml', __dir__)
      raw = File.read(yaml_path)
      erb = ERB.new(raw).result
      yaml = YAML.safe_load(erb, symbolize_names: true)

      # Environment variables override YAML values
      yaml[:rate_limit]  = (ENV['RATE_LIMIT'] || yaml[:rate_limit]).to_i
      yaml[:rate_window] = (ENV['RATE_WINDOW'] || yaml[:rate_window]).to_i
      yaml[:redis_url]   = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

      yaml
    rescue Errno::ENOENT => e
      raise "Configuration file not found: #{e.message}"
    rescue Psych::SyntaxError => e
      raise "YAML syntax error in configuration file: #{e.message}"
    end
  end
end