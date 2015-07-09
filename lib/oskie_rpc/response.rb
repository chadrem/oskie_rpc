module OskieRpc
  class Response
    attr_accessor :result
    attr_accessor :message_id

    def initialize(message_id = nil, result = nil)
      @message_id = message_id
      @result = result
    end

    def load(payload)
      @result = payload['response']['result']
      @message_id = payload['response']['messageId']

      self
    end

    def dump
      {
        'type' => 'rpcResponse',
        'response' => {
          'result' => @result,
          'messageId' => @message_id
        }
      }
    end
  end
end