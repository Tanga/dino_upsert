require 'spec_helper'

describe TN::HTTP do
  it 'should raise errors by default' do
    conn = described_class.default_connection
    VCR.use_cassette 'failing 418' do
      expect { conn.get('http://httpbin.org/status/418') }.to raise_error(TN::HTTP::ClientError)
    end

    VCR.use_cassette 'failing 500' do
      expect { conn.get('http://httpbin.org/status/503') }.to raise_error(TN::HTTP::ClientError)
    end

    VCR.use_cassette 'success' do
      conn.get('http://httpbin.org/status/200')
    end
  end

  # it 'should add Zlib::BufError to NET_HTTP_EXCEPTIONS' do
  #   expect(Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS).to include(Zlib::BufError)
  # end

  it 'can use net http persistent' do
    conn = described_class.default_connection('http://httpbin.org', adapter: :net_http_persistent)
    VCR.use_cassette('persistent') do
      2.times { conn.get('/status/200') }
    end
    expect(conn.builder.adapter.inspect).to be == "Faraday::Adapter::NetHttpPersistent"
  end
end
