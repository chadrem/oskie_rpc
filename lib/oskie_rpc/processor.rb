module OskieRpc
  class Processor
    def initialize(&block)
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
      @lock.synchronize do
        @input_chain << bytes
      end

      nil
    end

    def on(name, &block)
      @lock.synchronize do
        raise InvalidStateError unless @state == :initializing
        @callbacks[name.to_sym] = block
      end

      nil
    end

    def deliver(message)
      @lock.synchronize do
        raise InvalidStateError unless @state == :initialized
        raise InvalidClass, message.class.name unless message.is_a?(OskieRpc::Message)
        envelope = envelope_class.new(message)
        @output_chain << envelope.dump
      end

      nil
    end

    private

    def envelope_class
      Envelope
    end

    def create_input_chain
      FilterChain::Chain.new do |chain|
        chain.add(FilterChain::DemultiplexFilter.new)
        chain.add(FilterChain::DeserializeFilter.new(:format => :json))
        chain.add(FilterChain::ProcFilter.new { |contents| contents_handler(contents) })
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

    def contents_handler(contents)
      envelope = Envelope.new
      envelope.load(contents)

      envelope.message
    end

    def message_handler(message)
      @callbacks[:message].call(message)
    end

    def output_handler(bytes)
      @callbacks[:output].call(bytes)
    end
  end
end