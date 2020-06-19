# frozen_string_literal: true

module RippleToken
  class Configuration
    attr_accessor :base_url,
                  :realm,
                  :public_key_ttl,
                  :public_paths
  end
end
