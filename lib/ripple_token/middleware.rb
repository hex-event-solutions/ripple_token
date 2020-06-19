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

      unless token.public_path? method, path
        encoded_token = env['HTTP_AUTHORIZATION']&.gsub(/^Bearer /, '') || ''
        decoded_token = token.decode(encoded_token)
        store_user_details(decoded_token, env)
      end
      @app.call(env)
    end

    private

    def store_user_details(decoded_token, env)
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
