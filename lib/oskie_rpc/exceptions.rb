module OskieRpc
  class OskieRpcError < RuntimeError; end
  class MissingCallbackError < OskieRpcError; end
  class InvalidStateError < OskieRpcError; end
  class InvalidClass < OskieRpcError; end
  class UnknownMessageType < OskieRpcError; end
end