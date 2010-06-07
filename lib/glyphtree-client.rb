module GlyphTreeClient
	begin
		puts "loading GlyphTree Client config"
		env = ENV['RAILS_ENV'] || 'development'
		root = ENV['RAILS_ROOT'] || '.'
		gt_client_config = YAML::load(IO.read(root + "/config/glyphtree_client.yml"))[env]
	rescue Exception => e
		raise e
		raise "There was a problem with your config/glyphtree_client.yml file. Check and make sure it's present and that the syntax is correct."
	else
		Config = gt_client_config
	end
end

require 'glyphtree-client/utils'
require 'glyphtree-client/rest'
require 'glyphtree-client/glyph'
require 'glyphtree-client/transaction'
