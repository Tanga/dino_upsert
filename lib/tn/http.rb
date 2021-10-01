require 'faraday'
require 'faraday_middleware'

module TN
  module HTTP
    ClientError = Class.new(Faraday::ClientError)

    # TODO: remove this once this gets merged into Faraday
      # that never happened https://github.com/lostisland/faraday/pull/588
      #array is frozen in newer versions of faraday
    # Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS << Zlib::BufError

    class WrapError < Faraday::Middleware
      def call(env)
        @app.call(env)
      rescue Faraday::ServerError, Faraday::ClientError => e
        raise ClientError, e
      end
    end

    def self.default_connection(*arguments, adapter: Faraday.default_adapter)
      Faraday.new(*arguments) do |conn|
        conn.use TN::HTTP::WrapError
        conn.use Faraday::Response::RaiseError
        yield conn if block_given?
        conn.adapter(adapter)
      end
    end

    def self.form_connection(*arguments, adapter: nil)
      default_connection(*arguments, adapter: adapter) do |conn|
        conn.request  :url_encoded
        yield conn if block_given?
      end
    end

    def self.default_json_connection(*arguments, adapter: nil)
      default_connection(*arguments, adapter: adapter) do |conn|
        conn.response :mashify
        conn.response :json
        yield conn if block_given?
      end
    end
  end
end
