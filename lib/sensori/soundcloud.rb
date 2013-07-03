module Sensori
  module Soundcloud
    class << self

      attr_accessor :client_id, :secret, :app_client

      def client_id
        @client_id ||= APP_CONFIG['soundcloud']['client_id']
      end

      def secret
        @secret ||= APP_CONFIG['soundcloud']['secret']
      end

      def app_client
        @app_client ||= ::Soundcloud.new(:client_id => self.client_id, :client_secret => self.secret)
      end

    end
  end
end