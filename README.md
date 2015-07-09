# Oskie RPC [![Build Status](https://travis-ci.org/chadrem/oskie_rpc.svg)](https://travis-ci.org/chadrem/oskie_rpc)

Oskie RPC is an extremely simple and modular RPC library for Ruby.
Design goals include:

- Transport independent so no dependencies on TCP/IP, IO, or any other classes (it simply takes input and gives back output through callbacks).
- Modular design using the [Filter Chain](https://github.com/chadrem/filter_chain) gem so that the protocol can be modified if you so desire.
- Supports both messages and requests (requests can be replied to, messages can't).
- Very simple binary protocol with data encoded in JSON (you can easily change encoding formats).
- Thread safe.
- Easy to port to other languages.

## Installation

Add this line to your application's Gemfile:

    gem 'oskie_rpc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oskie_rpc

## Messages

The ````Message```` class is the basic unit of work for Oskie RPC.
Messages contain a few simple pieces of data:

- ````command````: The command lets you distinguish different types of messages.  An example is ````'chat'```` for a chat message.
- ````params````: Optional data you pass in addition to a command.  An example is ````{'message' => 'hello world'}```` for a chat message.

Messages are fire-and-forget.

## Requests

The ````Request```` class is a specialized type of message that expects a response.
You use these if you need a return value value from the other end.
Coming soon.

## Responses

The ````Response```` class is used to respond to a request.
Coming soon.

## Processors

The ````Processor```` class is the engine for Oskie RPC.
It is network agnostic and simply takes input, generates output, and executes callbacks.

    # Create a processor and define its callbacks.
    processor = OskieRpc::Processor.new do |p|
      p.on(:message) do |message|
        puts "Received message: #{message.inspect}"
      end

      p.on(:request) do |request|
        puts "Received request: #{request.inspect}"
      end

      p.on(:output) do |output|
        puts "Generated output: #{output.inspect}"
      end
    end

    # Send a message.
    message = OskieRpc::Message.new('hello', {'foo' => 'bar'})
    processor.deliver(message)

    # Simulate receiving a message.
    processor << "\u0000\u0000\u0000U{\"type\":\"rpcMessage\",\"message\":{\"command\":\"foo\",\"params\":{},\"messageId\":\"hardcoded\"}}"

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/oskie_rpc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

