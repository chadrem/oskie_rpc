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
      @command = payload['command']
      @params = payload['params']
      @message_id = payload['messageId']

      self
    end

    def dump
      {
        'command' => @command,
        'params' => @params,
        'messageId' => @message_id
      }
    end
  end
end