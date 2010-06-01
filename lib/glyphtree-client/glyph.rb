module GlyphTreeClient
	module Glyph
		class << self
			def parse_account_name(account_name)
				account_name = account_name.to_s if account_name.class == Symbol
				match = /([a-zA-Z0-9]*)@([a-zA-Z0-9]+)/.match(account_name)
				raise Exception, "Invalid account name format: #{account_name}. Expected [subname]@name" if match.nil?
				parsed = {
					:account => "#{match[1]}@#{match[2]}",
					:subaccount => (match[1].empty? ? nil : match[1]), 
					:glyph => match[2]
				}
			end

			def parse_currency_name(currency_name)
				currency_name = currency_name.to_s if currency_name.class == Symbol
				match = /%([a-zA-Z0-9]+)/.match(currency_name)
				raise Exception, "Invalid currency name format: #{currency_name}. Expected %name" if match.nil?
				parsed = {
					:glyph => match[1], 
					:currency => "%#{match[1]}",
					:account => "@#{match[1]}"
				}
			end
		end
	end
end
