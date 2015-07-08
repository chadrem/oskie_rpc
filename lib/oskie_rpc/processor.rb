module OskieRpc
  class Processor
    def initialize(opts = {}, &block)
      @opts = opts
      @lock = Mutex.new
      @input_chain = create_input_chain
      @output_chain = create_output_chain
      @callbacks = {}
      @state = :initializing
      block.call(self) if block
      raise MissingCallbackError, :message unless @callbacks[:message]
      raise MissingCallbackError, :output unless @callbacks[:output]
      @state = :initialized
    end

    def <<(bytes)
      @input_chain << bytes

      nil
    end

    def on(name, &block)
      @callbacks[name.to_sym] = block

      nil
    end

    def deliver(message)
      raise InvalidStateError unless @state == :initialized
      @output_chain << message.to_hash

      nil
    end

    private

    def create_input_chain
      FilterChain::Chain.new do |chain|
        chain.add(FilterChain::DemultiplexFilter.new)
        chain.add(FilterChain::DeserializeFilter.new(:format => :json))
        chain.add(FilterChain::Terminator.new { |message| message_handler(message) })
      end
    end

    def create_output_chain
      FilterChain::Chain.new do |chain|
        chain.add(FilterChain::SerializeFilter.new(:format => :json))
        chain.add(FilterChain::MultiplexFilter.new)
        chain.add(FilterChain::Terminator.new { |bytes| output_handler(bytes) })
      end
    end

    def message_handler(message)
      @callbacks[:message].call(message)
    end

    def output_handler(bytes)
      @callbacks[:output].call(bytes)
    end
  end
end