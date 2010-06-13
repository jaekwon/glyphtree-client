require 'helper'
include GlyphTreeClient

class TestGlyphtreeClient < Test::Unit::TestCase

	def test_send_sandbox
		trans_id = StringHelper.randid
		receiver = StringHelper.randid
		transaction = SwapTransaction.new(
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

		transaction = SwapTransaction.new(
			:id => StringHelper.randid, # TODO is there a way to not type  every time?!
			:diff => {
				"@sandbox/joe" => {
					"%sandbox" => 100,
				}
			},
			:comments => {
			}
		)
		transaction.execute

		query_id = StringHelper.randid
		query = Query.new(
			:id => query_id,
			:account => '@sandbox/joe',
			:currencies => ['%dollars']
		)
		result = query.execute
		assert_equal({'%dollars' => 0}, result, 'Query result was not expected')
	end

end
