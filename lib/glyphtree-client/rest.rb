require 'rest_client'
require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	module RestAPI
		def self.send_request(path, request)
			# POST to /path...
			request_url = "#{Config['base_api_url']}#{path}"
			response = RestClient.post request_url, request.to_json, :content_type=>:json, :accept=>:json
			return JSON.parse(response)
		end
	end

end
