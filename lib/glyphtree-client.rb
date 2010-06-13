module GlyphTreeClient
	begin
		env = ENV['RAILS_ENV'] || 'development'
		root = ENV['RAILS_ROOT'] || File.expand_path('../../', __FILE__)
		gt_client_config = YAML::load(IO.read(root + "/config/glyphtree_client.yml"))[env]
	rescue Exception => e
		raise e
		raise "There was a problem with your config/glyphtree_client.yml file. Check and make sure it's present and that the syntax is correct."
	else
		Config = gt_client_config
	end
end

require File.expand_path('../glyphtree-client/utils', __FILE__)
require File.expand_path('../glyphtree-client/gttp', __FILE__)
require File.expand_path('../glyphtree-client/rest', __FILE__)
require File.expand_path('../glyphtree-client/glyph', __FILE__)
require File.expand_path('../glyphtree-client/transaction', __FILE__)
require File.expand_path('../glyphtree-client/query', __FILE__)
