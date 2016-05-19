require 'faraday'
require 'faraday_middleware'

module TN
  module HTTP
    ClientError = Class.new(Faraday::ClientError)

    class WrapError < Faraday::Middleware
      def call(env)
        @app.call(env)
      rescue Faraday::ClientError => e
        raise ClientError, e
      end
    end

    def self.default_connection
      Faraday.new do |conn|
        conn.use TN::HTTP::WrapError
        conn.use Faraday::Response::RaiseError
        yield conn if block_given?
        conn.adapter Faraday.default_adapter
      end
    end

    def self.default_json_connection
      default_connection do |conn|
        conn.response :mashify
        conn.response :json
        yield conn if block_given?
      end
    end
  end
end
