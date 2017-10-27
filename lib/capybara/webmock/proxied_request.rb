require 'uri'

module Capybara
  module Webmock
    class ProxiedRequest
      attr_reader :referrer, :uri

      def initialize(raw_referrer, raw_uri)
        @referrer = raw_referrer == "-" ? nil : URI.parse(raw_referrer)
        @uri = URI.parse(raw_uri)
      end

      def fragment; @uri.fragment; end
      def host; @uri.host; end
      def hostname; @uri.hostname; end
      def password; @uri.password; end
      def path; @uri.path; end
      def port; @uri.port; end
      def query; @uri.query; end
      def scheme; @uri.scheme; end
      def user; @uri.user; end
      def userinfo; @uri.userinfo; end
    end
  end
end
