require 'forwardable'
require 'uri'

module Capybara
  module Webmock
    class ProxiedRequest
      extend Forwardable

      attr_reader :referrer, :uri

      def_delegators :uri, :fragment, :host, :hostname, :password, :path, :port, :query, :scheme, :user, :userinfo

      def initialize(raw_referrer, raw_uri)
        @referrer = raw_referrer == "-" ? nil : URI.parse(raw_referrer)
        @uri = URI.parse(raw_uri)
      end
    end
  end
end
