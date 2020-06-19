# frozen_string_literal: true

require 'httparty'
require 'json'
require 'active_support/core_ext/module/delegation'

require 'ripple_token/configuration'

module RippleToken
  class Client
    include HTTParty

    class << self
      delegate :public_paths, to: :configuration

      def configure
        @configuration = Configuration.new
        yield(configuration)
        fetch_public_key
        'Public key retrieved successfully'
      end

      def public_key
        fetch_public_key if (last_update_at + public_key_ttl) < Time.now

        @public_key
      end

      private

      delegate :base_url, :realm, :public_key_ttl, to: :configuration

      attr_accessor :last_update_at, :configuration

      def fetch_public_key
        response = get("#{base_url}/auth/realms/#{realm}")
        raw_public_key = "-----BEGIN PUBLIC KEY-----\n" \
                      "#{response['public_key']}\n" \
                      "-----END PUBLIC KEY-----"
        @public_key = OpenSSL::PKey::RSA.new raw_public_key
        @last_update_at = Time.now
      end
    end
  end
end
