# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module Oauth2
  module Provider
    class OauthAuthorization < ModelBase

      EXPIRY_TIME = 1.hour
      columns :user_id, :oauth_client_id, :code, :expires_at

      def self.find_all_by_oauth_client_id(client_id)
        find_collection(:find_all_oauth_authorization_by_client_id, client_id)
      end

      def self.find_by_code(code)
        find_one(:find_oauth_authorization_by_code, code)
      end

      def oauth_client
        OauthClient.find_by_id(oauth_client_id)
      end

      def generate_access_token
        token = oauth_client.create_token_for_user_id(user_id)
        self.destroy
        token
      end

      def expires_in
        (Time.at(expires_at.to_i) - Clock.now).to_i
      end

      def expired?
        expires_in <= 0
      end

      def before_create
        self.expires_at = (Clock.now + EXPIRY_TIME).to_i
        self.code = ActiveSupport::SecureRandom.hex(32)
      end

    end
  end
end