module Sensori
  module Soundcloud
    class << self

      attr_accessor :client_id, :secret, :app_client

      def client_id
        @client_id ||= ENV['SOUNDCLOUD_CLIENT_ID'].present? ? ENV['SOUNDCLOUD_CLIENT_ID'] : APP_CONFIG['soundcloud']['client_id']
      end

      def secret
        @secret ||= ENV['SOUNDCLOUD_SECRET'].present? ? ENV['SOUNDCLOUD_SECRET'] : APP_CONFIG['soundcloud']['secret']
      end

      def app_client
        @app_client ||= ::Soundcloud.new(:client_id => self.client_id, :client_secret => self.secret)
      end

    end
  end
end