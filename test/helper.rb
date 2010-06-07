ENV["RAILS_ENV"] = "test"
ENV["RAILS_ROOT"] = "."
require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'glyphtree-client'

class Test::Unit::TestCase
end
