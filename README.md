# Oskie RPC [![Build Status](https://travis-ci.org/chadrem/oskie_rpc.svg)](https://travis-ci.org/chadrem/oskie_rpc)

Oskie RPC is an extremely simple and modular RPC library for Ruby.
Design goals include:

- Transport independent so no dependencies on TCP/IP, IO, or any other classes (it simply takes input and gives back output through callbacks).
- Modular design using the [Filter Chain](https://github.com/chadrem/filter_chain) gem so that the protocol can be modified if you so desire.
- Supports both messages and requests (requests can be replied to, messages can't).
- Very simple binary protocol with data encoded in JSON.
- Thread safe.
- Easy to port to other languages.

## Installation

Add this line to your application's Gemfile:

    gem 'oskie_rpc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oskie_rpc

## Usage

Coming soon.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/oskie_rpc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

