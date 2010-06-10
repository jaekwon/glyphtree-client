module GlyphTreeClient
	module StringHelper
		def self.randid(length=12)
			chars = ["A".."Z","a".."z","0".."9"].collect { |r| r.to_a }.join
			return (1..length).collect { chars[rand(chars.size)] }.pack("C*")
		end
	end

	module RubyHelper
		def evaluate(&block) # for ease of variable assignments using blocks
			block.call
		end
	end
end
