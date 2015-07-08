module OskieRpc
  class OskieRpcError < RuntimeError; end
  class MissingCallbackError < OskieRpcError; end
  class InvalidStateError < OskieRpcError; end
end