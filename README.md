# RestRateLimiter

[![Ruby](https://img.shields.io/badge/Ruby-3.2-blue)](https://www.ruby-lang.org/)
[![Build Status](https://github.com/yourusername/RestRateLimiter/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/RestRateLimiter/actions)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Overview

**RestRateLimiter** is a production‑ready Rack middleware that provides per‑IP, per‑endpoint request throttling for any Ruby web application (Sinatra, Rails, etc.). 
It stores counters in Redis, supports configurable limits and windows, logs throttling events, and is fully testable.

## Features

- Configurable request limit and time window (seconds)
- Separate counters per IP address and request path
- Redis‑backed storage for horizontal scalability
- Graceful handling of Redis failures (fails‑open)
- Detailed logging with request metadata
- Environment‑driven configuration (`.env`) and YAML defaults
- RSpec test suite

## Prerequisites

- Ruby **≥ 3.0**
- Redis server
- Bundler (`gem install bundler`)

## Installation