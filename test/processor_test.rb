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

    processor.deliver({'foo' => 'bar'})

    assert_equal("\u0000\u0000\u0000\r{\"foo\":\"bar\"}", test_output)
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

    processor << "\u0000\u0000"
    processor << "\u0000\r{\"foo\":\"bar\"}"

    assert_equal({'foo' => 'bar'}, test_output)
  end
end