module Assimp

  MetadataType = enum(:metadata_type, [
    :BOOL,
    :INT32,
    :UINT64,
    :FLOAT,
    :DOUBLE,
    :AISTRING,
    :AIVECTOR3D
  ])

  class MetadataEntry < FFI::Struct
    layout :type, MetadataType,
           :data, :pointer
  end

  class Metadata < FFI::Struct
    layout :num_properties, :uint,
           :keys, :pointer, #String[num_properties]
           :values, :pointer #MetadataEntry[num_properties]
  end

end
