module OskieRpc
  class Envelope
    attr_accessor :message

    def initialize(message = nil)
      @message = message
    end

    def load(contents)
      @message = case contents['type']
      when 'rpcMessage' then Message.new
      when 'rpcRequest' then Request.new
      when 'rpcResponse' then Response.new
      else
        raise UnknownMessageType, contents['type']
      end

      @message.load(contents[namespace])

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
      when Message then 'rpcMessage'
      when Request then 'rpcRequest'
      when Response then 'rpcResponse'
      end
    end

    def namespace
      case type
      when 'rpcMessage' then 'message'
      when 'rpcRequest' then 'rpcRequest'
      when 'rpcResponse' then 'rpcResponse'
      end
    end
  end
end