module OskieRpc
  class Message
    attr_accessor :command
    attr_accessor :params
    attr_accessor :message_id
    attr_accessor :processor

    def initialize(command = '', params = {})
      @command = command
      @params = params
      @message_id = SecureRandom.uuid
    end

    def load(contents)
      @command = contents['command']
      @params = contents['params']
      @message_id = contents['messageId']

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