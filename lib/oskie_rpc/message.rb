module OskieRpc
  class Message
    attr_reader :command
    attr_reader :uuid
    attr_reader :data
    attr_reader :processor

    def initialize(command, opts = {})
      @command = command
      @uuid = opts[:uuid] || SecureRandom.uuid
      @data = opts[:data]
      @parser = opts[:processor]
    end

    def to_hash
      {
        :command => @command,
        :uuid => @uuid,
        :data => @data
      }
    end
  end
end