require 'test_helper'

class ProcessorTest < Minitest::Test
  def test_sending_a_message
    test_output = ""

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        raise 'This should never happen.'
      end

      p.on(:request) do |request|
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

  def test_receiving_a_message
    received_message = nil
    sent_bytes = nil

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        received_message = message
      end

      p.on(:request) do |request|
        raise 'This should never happen.'
      end

      p.on(:output) do |output|
        sent_bytes = output
      end
    end

    processor << "\u0000\u0000\u0000U{\"type\":\"rpcMessage\",\"message\":{\"command\":\"foo\",\"params\":{},\"messageId\":\"hardcoded\"}}"

    assert_instance_of(OskieRpc::Message, received_message)
    assert_equal("foo", received_message.command)
    assert_equal({}, received_message.params)
    assert_equal("hardcoded", received_message.message_id)
  end

  def test_sending_a_request_and_receiving_a_reply
    sent_bytes = nil
    received_response = nil

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        raise 'This should never happen.'
      end

      p.on(:request) do |request|
        raise 'This should never happen.'
      end

      p.on(:output) do |output|
        sent_bytes = output    
      end
    end

    request = OskieRpc::Request.new('bar', :dog => 'cat')
    request.on(:response) do |response|
      received_response = response
    end
    request.on(:failure) do
      raise 'This should never happen.'
    end
    request.message_id = 'hardcoded'
    processor.deliver(request)
    processor.heartbeat

    assert_equal("\u0000\u0000\u0000`{\"type\":\"rpcRequest\",\"request\":{\"command\":\"bar\",\"params\":{\"dog\":\"cat\"},\"messageId\":\"hardcoded\"}}", sent_bytes)
    
    processor << "\x00\x00\x00R{\"type\":\"rpcResponse\",\"response\":{\"result\":\"hello world\",\"messageId\":\"hardcoded\"}}"
    
    assert_instance_of(OskieRpc::Response, received_response)
    assert_equal("hardcoded", received_response.message_id)
    assert_equal("hello world", received_response.result)
  end

  def test_sending_a_request_and_having_it_timeout
    failure = false

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        raise 'This should never happen.'
      end

      p.on(:request) do |request|
        raise 'This should never happen.'
      end

      p.on(:output) do |output| 
      end
    end

    request = OskieRpc::Request.new('bar', :dog => 'cat')
    request.on(:response) do |response|
      raise 'This should never happen.'
    end
    request.on(:failure) do
      failure = true
    end
    request.message_id = 'hardcoded'
    request.timeout = -1
    processor.deliver(request)
    processor.heartbeat

    assert(failure)
  end

  def test_receiving_a_request_and_sending_a_reply
    received_request = nil
    sent_bytes = nil

    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        raise 'This should never happen.'
      end

      p.on(:request) do |request|
        received_request = request
        request.respond do
          "hello world"
        end
      end

      p.on(:output) do |output|
        sent_bytes = output
      end
    end

    processor << "\u0000\u0000\u0000U{\"type\":\"rpcRequest\",\"request\":{\"command\":\"foo\",\"params\":{},\"messageId\":\"hardcoded\"}}"
    
    assert_instance_of(OskieRpc::Request, received_request)
    assert_equal("foo", received_request.command)
    assert_equal({}, received_request.params)
    assert_equal("hardcoded", received_request.message_id)
    assert_equal("\x00\x00\x00R{\"type\":\"rpcResponse\",\"response\":{\"result\":\"hello world\",\"messageId\":\"hardcoded\"}}", sent_bytes)
  end
end