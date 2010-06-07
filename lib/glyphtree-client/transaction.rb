require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class Request
		def to_json
			raise NotImplementedError, 'you should subclass Request'
		end
	end

	class SwapTransaction < Request
		def initialize(params)
			@id = params[:id] || StringHelper.randid(12)
			@diff = params[:diff]
			@type = "SWAP/0.1"
			@comments = params[:comments] || {}
			@transaction_string = {'id'=>@id, 'diff'=>@diff, 'type'=>@type, 'comments'=>@comments}.to_json
			@signatures = {}
			self._sign
		end

		def _sign
			@diff.each do |account, a_diff|
				account_parsed = Glyph.parse_account_name(account)
				glyph = account_parsed[:glyph]
				next if @signatures.include? glyph # already been signed
				private_key = Config['secret_keys'][glyph]
				if private_key
					signature = Base64.encode64(OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA256.new, @transaction_string))
					@signatures[glyph] = signature
				else
					# TODO do something intelligent
				end
			end
			return self
		end

		def to_json
			return {'transaction'=>@transaction_string, 'signatures'=>@signatures}.to_json
		end

		def execute
			@signed_receipt = RestAPI.send_request('/transactions', self)
			# validate the signature of the receipt
			receipt_signature = @signed_receipt['signatures']['glyphtree']
			receipt_string = @signed_receipt['receipt']
			@receipt = JSON.parse(receipt_string)
			raise Exception, 'Invalid Receipt! (not the correct id)' if @receipt['transaction']['id'] != @id
			public_key = Config['public_keys']['glyphtree']
			raise Exception, 'Invalid Receipt! (not signed by glyphtree)' if not
				OpenSSL::PKey::RSA.new(public_key).verify(
					OpenSSL::Digest::SHA256.new, 
					Base64.decode64(@signed_receipt['signatures']['glyphtree']), 
					receipt_string
				)
		end

	end

end
