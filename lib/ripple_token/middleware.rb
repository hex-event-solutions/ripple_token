# frozen_string_literal: true

module RippleToken
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call env
    end

    def _call(env)
      method = env['REQUEST_METHOD']
      path = env['PATH_INFO']

      encoded_token = env['HTTP_AUTHORIZATION']&.gsub(/^Bearer /, '') || ''

      Client.logger.debug("Received #{encoded_token} token")

      if encoded_token.nil? || encoded_token&.empty?
        Client.logger.info('No token provided in request')
        raise MissingTokenError unless token.public_path? method, path
      else
        store_user_details(encoded_token, env)
      end

      @app.call(env)
    end

    private

    def store_user_details(encoded_token, env)
      env['keycloak.raw_token'] = encoded_token
      decoded_token = token.decode(encoded_token)

      env['keycloak.token'] = decoded_token
      env['keycloak.user_id'] = decoded_token['sub']
      env['keycloak.user_roles'] = decoded_token['realm_access']['roles']
      env['keycloak.user_email'] = decoded_token['email']
      env['keycloak.user_name'] = decoded_token['name']
      env['keycloak.user_first_name'] = decoded_token['given_name']
      env['keycloak.user_last_name'] = decoded_token['family_name']
      env['keycloak.user_phone'] = decoded_token['phone']
      env['keycloak.user_email_verified'] = decoded_token['email_verified']
      env['keycloak.user_groups'] = decoded_token['groups']
    end

    def token
      Token.new(Client.public_key)
    end
  end
end
