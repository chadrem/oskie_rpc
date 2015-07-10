# Oskie RPC [![Build Status](https://travis-ci.org/chadrem/oskie_rpc.svg)](https://travis-ci.org/chadrem/oskie_rpc)

Oskie RPC is an extremely simple and modular RPC library for Ruby.
Design goals include:

- Transport independent so no dependencies on TCP/IP, IO, or any other classes.
- Modular protocol design using the [Filter Chain](https://github.com/chadrem/filter_chain).
- Supports both messages and requests (requests can be replied to, messages can't).
- Very simple binary protocol with data encoded in JSON.
- Easy to port to other languages.
- Bi-directional.
- Thread safe.

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

- ````command````: This is how you distinguish different types of messages.
- ````params````: Optional data you pass in addition to a command.

Messages are fire-and-forget.

## Requests

The ````Request```` class is a specialized type of message that expects a response.
You use these if you need a return value value from the other end.
Requests support timeouts (see below section on heartbeats).
The default timeout is 60 seconds.

## Responses

The ````Response```` class is used to respond to a request.

In general you don't work directly with this class.
Responses are sent using the ````respond``` method on a request object.

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
        case request.command
        when 'echo'
          request.respond do
            request.params # Last expression of the block is the return value.
          end
        end
      end

      p.on(:output) do |output|
        puts "Generated output: #{output.inspect}"
      end
    end

    # Send a message.
    message = OskieRpc::Message.new('chat', 'hello world')
    processor.deliver(message)

    # Simulate receiving a request.
    processor << "\x00\x00\x00|{\"type\":\"rpcRequest\",\"request\":{\"command\":\"echo\",\"params\":\"hello world\",\"messageId\":\"6aa5f623-5823-4c54-a8db-cf911e9aecf8\"}}"

#### Heartbeats

Processors require an external clock signal to properly timeout requests.
This is done on purpose so that you can integrate with the timers provided by your networking framework or create your own using a dedicated thread.
Your clock should call the processors ````heartbeat```` method to signal that time has changed.
A good rule of thumb is to call this method once per second.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/oskie_rpc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

