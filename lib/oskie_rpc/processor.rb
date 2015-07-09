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
      raise MissingCallbackError, :request unless @callbacks[:request]
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

    def deliver(delivery)
      @lock.synchronize do
        raise InvalidStateError unless @state == :initialized
        @output_chain << delivery.dump
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
        chain.add(FilterChain::ProcFilter.new { |payload| payload_handler(payload) })
        chain.add(FilterChain::Terminator.new { |delivery| delivery_handler(delivery) })
      end
    end

    def create_output_chain
      FilterChain::Chain.new do |chain|
        chain.add(FilterChain::SerializeFilter.new(:format => :json))
        chain.add(FilterChain::MultiplexFilter.new)
        chain.add(FilterChain::Terminator.new { |bytes| output_handler(bytes) })
      end
    end

    def payload_handler(payload)
      message = case payload['type']
      when 'rpcMessage' then Message.new
      when 'rpcRequest' then Request.new
      when 'rpcResponse' then Response.new
      else
        raise UnknownPayloadTypeError, payload['type']
      end

      message.load(payload)
    end

    def delivery_handler(delivery)
      case delivery
      when Message then @callbacks[:message].call(delivery)
      when Request then @callbacks[:request].call(delivery)
      when Response then raise 'Coming soon'
      else
        raise UnknownDeliveryClassError, message.class.name
      end
    end

    def output_handler(bytes)
      @callbacks[:output].call(bytes)
    end
  end
end