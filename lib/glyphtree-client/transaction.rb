require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class SwapTransaction
		def initialize(params)
			@id = params[:id] || StringHelper.randid(12)
			@diff = params[:diff]
			@comments = params[:comments] || {}
			@transaction_string = {'id'=>@id, 'diff'=>@diff, 'comments'=>@comments}.to_json
			@signatures = {}
		end

		def sign
			@diff.each do |account, a_diff|
				account_parsed = Glyph.parse_account_name(account)
				glyph = account_parsed[:glyph]
				next if @signatures.include? glyph # already been signed
				private_key = GlyphTreeClient::Config['secret_keys'][glyph]
				if private_key
					signature = Base64.encode64(OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA256.new, @transaction_string))
					@signatures[glyph] = signature
				else
					# TODO do something intelligent
				end
			end
			return self
		end

		def to_s
			return {'transaction'=>@transaction_string, 'signatures'=>@signatures}.to_json
		end
	end

end
