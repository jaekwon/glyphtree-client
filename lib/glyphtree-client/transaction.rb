require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class SwapTransaction < GTTPRequest
		def initialize(params)
			super params.merge(:type => 'SWAP/0.1', :request_path => '/transactions')
			@request['diff'] = @diff = params[:diff]
			@request['comments'] = @comments = params[:comments] || {}
			@request_string = @request.to_json
			@diff.each do |account, _|
				self.add_signature_for_account(account)
			end
		end
	end
end
