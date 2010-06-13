require 'json'
require 'openssl'
require 'base64'

module GlyphTreeClient

	class GTTPRequest
		include RubyHelper

		def initialize(params)
			@request_path = params[:request_path] or raise Exception, 'Must specify the GTTPRequest request path!'
			@type = params[:type] or raise Exception, 'Must specify the GTTPRequest type!'
			@id = params[:id] || StringHelper.randid(12)
			@expiration = nil
			@request = {'id'=>@id, 'type'=>@type, 'expiration'=>@expiration}
			@request_string = nil # set it once in the subclass to @request.to_json
			@signatures = {}
		end

		def add_signature_for_account(account)
			account_parsed = Glyph.parse_account_name(account)
			glyph = account_parsed[:glyph]
			next if @signatures[glyph]
			private_key = Config['secret_keys'][glyph]
			if private_key
				signature = Base64.encode64(OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA256.new, @request_string))
				@signatures[glyph] = signature
			else
				# TODO do something intelligent
			end
		end

		def to_json
			return {'request'=>@request_string, 'signatures'=>@signatures}.to_json
		end

		def execute
			return if @result # already executed
			@response = RestAPI.send_request(@request_path, self)
			# validate the signature of the result
			result_signature = @response['signatures']['glyphtree']
			result_string = @response['result']
			@result = JSON.parse(result_string)
			raise Exception, 'Invalid result! (not the correct id)' if @result['request']['id'] != @id
			public_key = Config['public_keys']['glyphtree']
			raise Exception, 'Invalid result! (not signed by glyphtree)' if not
				OpenSSL::PKey::RSA.new(public_key).verify(
					OpenSSL::Digest::SHA256.new, 
					Base64.decode64(result_signature),
					result_string
				)
			return @result
		end
	end
end
