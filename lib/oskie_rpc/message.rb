module OskieRpc
  class Message
    attr_accessor :command
    attr_accessor :params
    attr_accessor :message_id

    def initialize(command = '', params = {})
      @command = command
      @params = params
      @message_id = SecureRandom.uuid
    end

    def load(payload)
      @command = payload['message']['command']
      @params = payload['message']['params']
      @message_id = payload['message']['messageId']

      self
    end

    def dump
      {
        'type' => 'rpcMessage',
        'message' => {
          'command' => @command,
          'params' => @params,
          'messageId' => @message_id
        }
      }
    end
  end
end