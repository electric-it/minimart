require 'rest_client'

module Minimart
  module Utils
    module Http
      def self.get_json(url, sub_url = nil)
        JSON.parse(get(url, sub_url))
      end

      def self.get(base_url, sub_url = nil)
        site = RestClient::Resource.new(base_url.to_s)
        sub_url ? site[sub_url].get : site.get
      end

      def self.get_binary(base_name, url, sub_url = nil)
        result = Tempfile.new(base_name)
        result.binmode
        result.write(get(url, sub_url))
        result.close(false)
        result
      end
    end
  end
end
