require 'rest_client'
require 'uri'

module Minimart
  module Utils
    # A collection of methods to help issue HTTP requests
    module Http

      # Issue a GET request to a URL, and return parsed JSON.
      # @param [String] url The base URL to hit
      # @param [String] path The path to the RESTful resource to fetch
      # @return [Hash] The parsed JSON response
      def self.get_json(url, path=nil)
        JSON.parse(get(url, path, accept: 'application/json'))
      end

      # Issue a GET request to a URL
      # @param [String] base_url The base URL to hit
      # @param [String] path The path to the RESTful resource to fetch
      def self.get(base_url, path=nil, headers={})
        headers = headers.merge(verify_ssl: Minimart::Configuration.verify_ssl)

        resource = RestClient::Resource.new(base_url.to_s)
        path ? resource[path].get(headers) : resource.get(headers)
      end

      # GET a binary file
      # @param [String] base_name A base name to give the returned file
      # @param [String] url The base URL to hit
      # @param [String] path The path to the RESTful resource to fetch
      # @return [Tempfile]
      def self.get_binary(base_name, url, path=nil)
        result = Tempfile.new(base_name)
        result.binmode
        result.write(get(url, path))
        result.close(false)
        result
      end

      # Build a URL from a base URL, and a path
      # @param [String] base_url The base URL to hit
      # @param [String] path
      def self.build_url(base_url, path=nil)
        result = (base_url =~ /\A[a-z].*:\/\//i) ? base_url : "http://#{base_url}"
        result = URI.parse(result).to_s
        result = concat_url_fragment(result, path)
        return result
      end

      def self.concat_url_fragment(frag_one, frag_two)
        return frag_one unless frag_two
        result = frag_one
        result << '/' unless result[-1] == '/'
        result << ((frag_two[0] == '/') ? frag_two[1..-1] : frag_two)
        result
      end

    end
  end
end
