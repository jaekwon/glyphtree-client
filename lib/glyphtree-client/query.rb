require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class BalanceQuery < GTTPRequest
		def initialize(params)
			super params.merge(:type => 'BALANCE/0.1', :request_path => '/queries')
			@request['account'] = @account = params[:account]
			@request['currencies'] = @currencies = params[:currencies]
			@request_string = @request.to_json
			self.add_signature_for_account(@account)
		end
	end

	class ListAccountQuery < GTTPRequest
		def initialize(params)
			super params.merge(:type => 'LIST/0.1', :request_path => '/queries')
			@request['account'] = @account = params[:account]
			@request_string = @request.to_json
			self.add_signature_for_account(@account)
		end
	end
end
