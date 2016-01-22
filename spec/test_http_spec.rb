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
end
