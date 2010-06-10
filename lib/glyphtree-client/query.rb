require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class QueryTransaction < Request
		include RubyHelper

		def initialize(params)
			@id = params[:id] || StringHelper.randid(12)
			@type = "QUERY/0.1"
			@account = params[:account]
			@currencies = params[:currencies]
			@expiration = nil
			@query_string = {'id'=>@id, 'type'=>@type, 'account'=>@account, 'currencies'=>@currencies, 'expiration'=>@expiration}.to_json
			@signature = nil
			self._sign
		end

		def _sign
			@signature ||= evaluate do
				account_parsed = Glyph.parse_account_name(@account)
				glyph = account_parsed[:glyph]
				next if @signature # already been signed
				private_key = Config['secret_keys'][glyph]
				if private_key
					next Base64.encode64(OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA256.new, @query_string))
				else
					next nil # TODO do something more intelligent
				end
			end
		end

		def to_json
			return {'query'=>@query_string, 'signature'=>@signature}.to_json
		end

		def execute
			@receipt ||= evaluate do
				@signed_receipt = RestAPI.send_request('/queries', self)
				# validate the signature of the receipt
				receipt_signature = @signed_receipt['signatures']['glyphtree']
				receipt_string = @signed_receipt['receipt']
				public_key = Config['public_keys']['glyphtree']
				raise Exception, 'Invalid Receipt! (not signed by glyphtree)' if not
					OpenSSL::PKey::RSA.new(public_key).verify(
						OpenSSL::Digest::SHA256.new, 
						Base64.decode64(receipt_signature),
						receipt_string
					)
				next JSON.parse(receipt_string)
			end

			return @receipt['balances']
		end

	end

end
