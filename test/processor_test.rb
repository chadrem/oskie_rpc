require 'test_helper'

class ProcessorTest < Minitest::Test
  def test_output
    test_output = ""

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        raise 'This should never happen.'
      end

      p.on(:output) do |output|
        test_output << output    
      end
    end

    message = OskieRpc::Message.new('foo')
    message.message_id = 'hardcoded'
    processor.deliver(message)
    assert_equal("\u0000\u0000\u0000U{\"type\":\"rpcMessage\",\"message\":{\"command\":\"foo\",\"params\":{},\"messageId\":\"hardcoded\"}}", test_output)
  end

  def test_input
    test_output = nil

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        test_output = message
      end

      p.on(:output) do |output|
        raise 'This should never happen.'
      end
    end

    processor << "\u0000\u0000\u0000U{\"type\":\"rpcRequest\",\"request\":{\"command\":\"foo\",\"params\":{},\"messageId\":\"hardcoded\"}}"
    assert_instance_of(OskieRpc::Request, test_output)
    assert_equal("foo", test_output.command)
    assert_equal({}, test_output.params)
    assert_equal("hardcoded", test_output.message_id)
  end
end