# frozen_string_literal: true

module RippleToken
  class Token
    def initialize(public_key)
      @public_key = public_key
    end

    def decode(token)
      raise MissingTokenError if token.nil? || token&.empty?

      begin
        decoded_token = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
        raise ExpiredTokenError if expired? decoded_token

        decoded_token
      rescue JWT::DecodeError => e
        raise TokenDecodeError, e.message
      rescue JWT::ExpiredSignature => e
        raise ExpiredTokenError, e.message
      end
    end

    def public_path?(method, path)
      return false if Client.public_paths.nil? || Client.public_paths.empty?

      return true if Client.public_paths[method]&.include? path

      false
    end

    private

    attr_reader :public_key

    def expired?(token)
      expiration = Time.at(token['exp'])
      expiration < Time.now
    end
  end
end
