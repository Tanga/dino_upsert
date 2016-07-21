require 'faraday'
require 'faraday_middleware'

module TN
  module HTTP
    ClientError = Class.new(Faraday::ClientError)

    # TODO: remove this once this gets merged into Faraday
    Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS << Zlib::BufError
    Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS << Errno::EPIPE

    class WrapError < Faraday::Middleware
      def call(env)
        @app.call(env)
      rescue Faraday::ClientError => e
        raise ClientError, e
      end
    end

    def self.default_connection(*arguments)
      Faraday.new(*arguments) do |conn|
        conn.use TN::HTTP::WrapError
        conn.use Faraday::Response::RaiseError
        yield conn if block_given?
        conn.adapter Faraday.default_adapter
      end
    end

    def self.form_connection(*arguments)
      default_connection(*arguments) do |conn|
        conn.request  :url_encoded
        yield conn if block_given?
      end
    end

    def self.default_json_connection(*arguments)
      default_connection(*arguments) do |conn|
        conn.response :mashify
        conn.response :json
        conn.request :retry
        yield conn if block_given?
      end
    end
  end
end
