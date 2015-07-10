module OskieRpc
  class Response < Package
    attr_accessor :result

    def initialize(message_id = nil, result = nil)
      @message_id = message_id
      @result = result
    end

    def load(payload)
      @result = payload['response']['result']
      @message_id = payload['response']['messageId']

      validate!

      self
    end

    def dump
      validate!

      {
        'type' => 'rpcResponse',
        'response' => {
          'result' => @result,
          'messageId' => @message_id
        }
      }
    end

    def validate!
      @message_id.is_a?(String) || raise(ValidationError, "Message ID is not a string.")

      nil
    end
  end
end