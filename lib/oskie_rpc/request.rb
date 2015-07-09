module OskieRpc
  class Request
    attr_accessor :command
    attr_accessor :params
    attr_accessor :message_id

    def initialize(command = '', params = {})
      @command = command
      @params = params
      @message_id = SecureRandom.uuid
    end

    def load(payload)
      @command = payload['request']['command']
      @params = payload['request']['params']
      @message_id = payload['request']['messageId']

      self
    end

    def dump
      {
        'type' => 'rpcRequest',
        'request' => {
          'command' => @command,
          'params' => @params,
          'messageId' => @message_id
        }
      }
    end
  end
end