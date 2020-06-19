# frozen_string_literal: true

module RippleToken
  class Railtie < Rails::Railtie
    railtie_name :ripple_token

    initializer 'ripple_token.insert_middleware' do |app|
      app.config.middleware.use(RippleToken::Middleware)
    end
  end
end
