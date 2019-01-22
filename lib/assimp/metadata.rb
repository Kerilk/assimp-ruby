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
    extend StructAccessors
    layout :type, MetadataType,
           :data, :pointer
    struct_attr_accessor :type

    def data
      d = self[:data]
      case type
      when :BOOL
        d.read_uint != 0
      when :INT32
        d.read_int
      when :UINT64
        d.read(find_type(:uint64))
      when :FLOAT
        d.read_float
      when :DOUBLE
        d.read_double
      when :AISTRING
        s = d.read_uint
        self[:data].get_string(4, s)
      when :AIVECTOR3D
        Vector3D::new(d)
      else
        raise "Unknown MetadataType : #{type}!"
      end
    end
  end

  class Metadata < FFI::Struct
    extend StructAccessors
    layout :num_properties, :uint,
           :keys, :pointer, #String[num_properties]
           :values, :pointer #MetadataEntry[num_properties]
    struct_attr_accessor :num_properties
    struct_array_attr_reader [:values, MetadataEntry, :num_properties],
                             [:keys, String, :num_properties]
  end

end
