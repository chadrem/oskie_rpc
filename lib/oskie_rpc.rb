# Ruby std lib.
require "securerandom"
require "json"

# Core.
require "oskie_rpc/version"
require "message"
require "processor"

# Input filters.
require "unpack_filter"
require "unzip_filter"
require "deserialize_filter"

# Output filters.
require "serialize_filter"
require "zip_filter"
require "pack_filter"


module OskieRpc
  @input_filters = [
    {:class => UnpackFilter},
    {:class => UnzipFilter},
    {:class => DeserializeFilter}
  ]
  @output_filters = [
    {:class => SerializeFilter},
    {:class => ZipFilter},
    {:class => PackFilter}
  ]

  class << self
    attr_accessor :input_filters
    attr_accessor :output_filters
  end
end
