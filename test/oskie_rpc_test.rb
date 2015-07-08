require 'test_helper'

class OskieRpcTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OskieRpc::VERSION
  end
end
