module OskieRpc
  class Request < Package
    attr_accessor :command
    attr_accessor :params
    attr_accessor :timeout # Seconds.

    def initialize(command = '', params = {})
      @command = command
      @params = params
      @timeout = 60
      @message_id = SecureRandom.uuid
      @callbacks = {}
      @state = :initialized
    end

    def <=>(request)
      timeout_at <=> request.timeout_at
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

    def on(name, &block)
      @callbacks[name.to_sym] = block
    end

    def timed_out?
      Time.now.utc > timeout_at
    end

    def timeout_at
      @sent_at + timeout
    end

    def respond
      raise InvalidStateError unless @state == :received
      response = Response.new(message_id)
      response.result = yield
      @processor.deliver(response)

      nil
    end

    #
    # Private API for use by Processor only.
    #

    def __request_sent
      @state = :sent
      @sent_at = Time.now.utc
    end

    def __request_received(processor)
      @state = :received
      @processor = processor
    end

    def __response_received(response)
      @state = :responded
      @callbacks[:response].call(response) if @callbacks[:response]
    end

    def __response_failed
      @state = :failed
      @callbacks[:failure].call if @callbacks[:failure]
    end
  end
end