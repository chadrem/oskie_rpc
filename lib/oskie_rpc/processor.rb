module OskieRpc
  class Processor
    def initialize(opts = {})
      @opts = opts
      @lock = Mutex.new
      @input_chain = create_chain(opts[:input_chain] || OskieRpc.input_chain)
      @output_chain = create_chain(opts[:output_chain] || OskieRpc)
    end

    def input(bytes)
    end

    def heartbeat
    end

    private

    def on_receive_message(message)
    end

    def on_output(bytes)
    end
  end
end