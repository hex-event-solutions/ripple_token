# frozen_string_literal: true

require 'jwt'

require 'ripple_token/version'
require 'ripple_token/client'
require 'ripple_token/middleware'
require 'ripple_token/token'
require 'ripple_token/railtie' if defined?(Rails)

module RippleToken
  class Error < StandardError; end
  class ExpiredTokenError < Error; end
  class TokenDecodeError < Error; end
  class MissingTokenError < Error; end
end
