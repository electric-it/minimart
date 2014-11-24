module Minimart
  module Utils
    module Http
      def self.get_json(url)
        response = RestClient.get(url.to_s)
        JSON.parse(response)
      end
    end
  end
end
