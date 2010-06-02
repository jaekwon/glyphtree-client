module GlyphTreeClient
	module Glyph
		class << self
			def parse_account_name(account_name)
				account_name = account_name.to_s if account_name.class == Symbol
				match = /@([a-zA-Z0-9]+)(\/[a-zA-Z0-9]+)?/.match(account_name)
				raise Exception, "Invalid account name format: #{account_name}. Expected @name[/subname]" if match.nil?
				parsed = {
					:glyph => match[1],
					:account => account_name,
					:subaccount => (match[2].empty? ? nil : match[2]), 
				}
			end

			def parse_currency_name(currency_name)
				currency_name = currency_name.to_s if currency_name.class == Symbol
				match = /%([a-zA-Z0-9]+)(\/[a-zA-Z0-9]+)?/.match(currency_name)
				raise Exception, "Invalid currency name format: #{currency_name}. Expected %name[/subname]" if match.nil?
				parsed = {
					:glyph => match[1],
					:currency => currency_name,
					:subcurrency => match[2].empty? ? nil : match[2],
				}
			end
		end
	end
end
