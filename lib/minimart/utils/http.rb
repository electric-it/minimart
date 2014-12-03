require 'rest_client'

module Minimart
  module Utils
    module Http
      def self.get_json(url)
        JSON.parse(get(url))
      end

      def self.get(url)
        RestClient.get(url.to_s)
      end

      def self.get_binary(base_name, url)
        result = Tempfile.new(base_name)
        result.binmode
        result.write(get(url))
        result.close(false)
        result
      end
    end
  end
end
