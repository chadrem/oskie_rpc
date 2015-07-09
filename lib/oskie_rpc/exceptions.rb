module OskieRpc
  class OskieRpcError < RuntimeError; end
  class MissingCallbackError < OskieRpcError; end
  class InvalidStateError < OskieRpcError; end
  class InvalidClassError < OskieRpcError; end
  class UnknownMessageTypeError < OskieRpcError; end
  class UnknownMessageClassError < OskieRpcError; end
  class UnknownMessageNamespaceError < OskieRpcError; end
end