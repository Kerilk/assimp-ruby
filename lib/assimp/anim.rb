module Assimp

  class VectorKey < FFI::Struct
    extend StructAccessors
    layout :time, :double,
           :value, Vector3D
    struct_attr_accessor :time,
                         :value
  end

  class QuatKey < FFI::Struct
    extend StructAccessors
    layout :time, :double,
           :value, Quaternion
    struct_attr_accessor :time,
                         :value
  end

  class MeshKey < FFI::Struct
    extend StructAccessors
    layout :time, :double,
           :value, :uint
    struct_attr_accessor :time,
                         :value
  end

  class MeshMorphKey < FFI::Struct
    extend StructAccessors
    layout :time, :double,
           :values, :pointer, #uint[num_values_and_weights]
           :weights, :pointer, #double[num_values_and_weights]
           :num_values_and_weights, :uint
    struct_attr_accessor :time,
                         :num_values_and_weights
    struct_array_attr_accessor [:values, :uint, :num_values_and_weights],
                               [:weights, :double, :num_values_and_weights]
  end

  AnimBehaviour = enum(:anim_behavior, [
    :DEFAULT,
    :CONSTANT,
    :LINEAR,
    :REPEAT
  ])

  class NodeAnim < FFI::Struct
    extend StructAccessors
    layout :node_name, String,
           :num_position_keys, :uint,
           :position_keys, :pointer, #VectorKey
           :num_rotation_keys, :uint,
           :rotation_keys, :pointer, #QuatKey
           :num_scaling_keys, :uint,
           :scaling_keys, :pointer, #VectorKey
           :pre_state, AnimBehaviour,
           :post_state, AnimBehaviour
    struct_attr_accessor :node_name,
                         :num_position_keys,
                         :num_rotation_keys,
                         :num_scaling_keys,
                         :pre_state,
                         :post_state

    struct_array_attr_accessor [:position_keys, VectorKey],
                               [:rotation_keys, QuatKey],
                               [:scaling_keys, VectorKey]

    def to_s
      node_name
    end

  end

  class MeshAnim < FFI::Struct
    extend StructAccessors
    layout :name, String,
           :num_keys, :uint,
           :keys, :pointer #MeshKey
    struct_attr_accessor :name,
                         :num_keys
    struct_array_attr_accessor [:keys, MeshKey]

    def to_s
      name
    end

  end

  class MeshMorphAnim < FFI::Struct
    extend StructAccessors
    layout :name, String,
           :num_keys, :uint,
           :keys, :pointer #MeshMorphKey
    struct_attr_accessor :name,
                         :num_keys
    struct_array_attr_accessor [:keys, MeshMorphKey]

    def to_s
      name
    end

  end

  class Animation < FFI::Struct
    extend StructAccessors
    layout :name, String,
           :duration, :double,
           :ticks_per_second, :double,
           :num_channels, :uint,
           :channels, :pointer, #NodeAnim*
           :num_mesh_channels, :uint,
           :mesh_channels, :pointer, #MeshAnim*
           :num_morph_mesh_channels, :uint,
           :morph_mesh_channels, :pointer #MeshMorphAnim*
    struct_attr_accessor :name,
                         :duration,
                         :ticks_per_second,
                         :num_channels,
                         :num_mesh_channels,
                         :num_morph_mesh_channels
    struct_ref_array_attr_accessor [:channels, NodeAnim],
                                   [:mesh_channels, MeshAnim],
                                   [:morph_mesh_channels, MeshMorphAnim]

    def to_s
      name
    end

  end

end
