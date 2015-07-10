module OskieRpc
  class Processor
    def initialize(&block)
      @lock = Monitor.new
      @input_chain = create_input_chain
      @output_chain = create_output_chain
      @callbacks = {}
      @requests = SortedSet.new
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

        if delivery.is_a?(Request)
          delivery.__request_sent
          @requests << delivery
        end

        @output_chain << delivery.dump
      end

      nil
    end

    def heartbeat
      @lock.synchronize do
        @requests.each do |request|
          if request.timed_out?
            @requests.delete(request)
            request.__response_failed
          else
            return
          end
        end
      end

      nil
    end

    private

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
      when Message then message_handler(delivery)
      when Request then request_handler(delivery)
      when Response then response_handler(delivery)
      else
        raise UnknownDeliveryClassError, message.class.name
      end
    end

    def message_handler(message)
      @callbacks[:message].call(message)
    end

    def request_handler(request)
      request.__request_received(self)
      @callbacks[:request].call(request)
    end

    def response_handler(response)
      request = @requests.find { |request| request.message_id == response.message_id }
      return unless request
      @requests.delete(request) 
      request.__response_received(response)
    end


    def output_handler(bytes)
      @callbacks[:output].call(bytes)
    end
  end
end