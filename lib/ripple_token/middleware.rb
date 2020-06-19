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

      if token.public_path? method, path
        @app.call(env)
      else
        encoded_token = env['HTTP_AUTHORIZATION']&.gsub(/^Bearer /, '') || ''
        decoded_token = token.decode(encoded_token)
        store_user_details(decoded_token)
      end
    end

    private

    def store_user_details(decoded_token, env)
      env['KEYCLOAK_TOKEN'] = decoded_token
      env['KEYCLOAK_USER_ID'] = decoded_token['sub']
      env['KEYCLOAK_USER_ROLES'] = decoded_token['realm_access']['roles']
      env['KEYCLOAK_USER_EMAIL'] = decoded_token['email']
      env['KEYCLOAK_USER_NAME'] = decoded_token['name']
      env['KEYCLOAK_USER_FIRST_NAME'] = decoded_token['given_name']
      env['KEYCLOAK_USER_LAST_NAME'] = decoded_token['family_name']
      env['KEYCLOAK_USER_PHONE'] = decoded_token['phone']
      env['KEYCLOAK_USER_EMAIL_VERIFIED'] = decoded_token['email_verified']
    end

    def token
      Token.new(Client.public_key)
    end
  end
end
