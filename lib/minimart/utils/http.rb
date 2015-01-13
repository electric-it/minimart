require 'rest_client'
require 'uri'

module Minimart
  module Utils
    module Http

      def self.get_json(url, sub_url=nil)
        JSON.parse(get(url, sub_url))
      end

      def self.get(base_url, sub_url=nil)
        site = RestClient::Resource.new(base_url.to_s)
        sub_url ? site[sub_url].get : site.get
      end

      def self.get_binary(base_name, url, sub_url=nil)
        result = Tempfile.new(base_name)
        result.binmode
        result.write(get(url, sub_url))
        result.close(false)
        result
      end

      def self.build_url(base_url, sub_url=nil)
        result = (base_url =~ /\A[a-z].*:\/\//i) ? base_url : "http://#{base_url}"
        result = URI.parse(result).to_s
        if sub_url
          result << '/' unless result[-1] == '/'
          result << ((sub_url[0] == '/') ? sub_url[1..-1] : sub_url)
        end
        return result
      end

    end
  end
end
