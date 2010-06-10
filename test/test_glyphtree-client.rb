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

	def test_query_sandbox

		transaction = GlyphTreeClient::SwapTransaction.new(
			:id => GlyphTreeClient::StringHelper.randid, # TODO is there a way to not type GlyphTreeClient:: every time?!
			:diff => {
				"@sandbox/joe" => {
					"%sandbox" => 100,
				}
			},
			:comments => {
			}
		)
		# transaction.execute

		query_id = GlyphTreeClient::StringHelper.randid
		query = GlyphTreeClient::QueryTransaction.new(
			:id => query_id,
			:account => '@sandbox/joe',
			:currencies => ['%dollars']
		)
		results = query.execute
		assert_equal({'%dollars' => 0}, results, 'Query result was not expected')
	end

end
