module OskieRpc
  class Envelope
    attr_accessor :message

    def initialize(message = nil)
      @message = message
    end

    def load(payload)
      @message = case payload['type']
      when 'rpcMessage' then Message.new
      when 'rpcRequest' then Request.new
      when 'rpcResponse' then Response.new
      else
        raise UnknownMessageTypeError, payload['type']
      end

      @message.load(payload[namespace])

      self
    end

    def dump
      {
        'type' => type,
        namespace => message.dump
      }
    end

    private

    def type
      case @message
      when Request then 'rpcRequest'
      when Response then 'rpcResponse'
      when Message then 'rpcMessage'
      else
        raise UnknownMessageClassError, @message.class.name
      end
    end

    def namespace
      case type
      when 'rpcRequest' then 'request'
      when 'rpcResponse' then 'response'
      when 'rpcMessage' then 'message'
      else
        raise UnknownMessageNamespaceError, @message.class.name
      end
    end
  end
end