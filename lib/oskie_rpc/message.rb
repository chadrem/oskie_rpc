module OskieRpc
  class Message < Package
    attr_accessor :command
    attr_accessor :params

    def initialize(command = '', params = {})
      @command = command
      @params = params
      @message_id = SecureRandom.uuid
    end

    def load(payload)
      @command = payload['message']['command']
      @params = payload['message']['params']
      @message_id = payload['message']['messageId']

      validate!

      self
    end

    def dump
      validate!

      {
        'type' => 'rpcMessage',
        'message' => {
          'command' => @command,
          'params' => @params,
          'messageId' => @message_id
        }
      }
    end

    def validate!
      @command.is_a?(String) || raise(ValidationError, "Command is not a string.")
      @params.is_a?(Hash) || raise(ValidationError, "Params is not a hash.")
      @message_id.is_a?(String) || raise(ValidationError, "Message ID is not a string.")

      nil
    end
  end
end