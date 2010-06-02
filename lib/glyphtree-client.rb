module GlyphTreeClient
	begin
		puts "loading GlyphTree Client config"
		env = ENV['RAILS_ENV'] || 'development'
		gt_client_config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/glyphtree_client.yml")).result)[env]
	rescue
		raise "There was a problem with your config/glyphtree_client.yml file. Check and make sure it's present and the syntax is correct."
	else
		Config = gt_client_config
	end
end

require 'glyphtree-client/utils'
require 'glyphtree-client/rest'
require 'glyphtree-client/glyph'
require 'glyphtree-client/transaction'

