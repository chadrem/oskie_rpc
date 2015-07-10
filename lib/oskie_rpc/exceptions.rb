module OskieRpc
  class OskieRpcError < RuntimeError; end
  class MissingCallbackError < OskieRpcError; end
  class InvalidStateError < OskieRpcError; end
  class UnknownPayloadTypeError < OskieRpcError; end
  class UnknownDeliveryClassError < OskieRpcError; end
  class ValidationError < OskieRpcError; end
end