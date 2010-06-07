require 'helper'

class TestGlyphtreeClient < Test::Unit::TestCase

	def test_send_sandbox
		trans_id = GlyphTreeClient::StringHelper.randid
		receiver = GlyphTreeClient::StringHelper.randid
		transaction = GlyphTreeClient::SwapTransaction.new(
			:id => trans_id,
			:diff => {
				"@sandbox/#{receiver}" => {
					"%sandbox" => 100,
				}
			},
			:comments => {
			}
		)
		transaction.execute
	end

end
