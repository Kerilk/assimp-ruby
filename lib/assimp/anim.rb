module Assimp

  class VectorKey < FFI::Struct
    layout :time, :double,
           :value, Vector3D
  end

  class QatKey < FFI::Struct
    layout :time, :double,
           :value, Quaternion
  end

  class MeshKey < FFI::Struct
    layout :time, :double,
           :value, :uint
  end

  class MeshMorphKey < FFI::Struct
    layout :time, :double,
           :values, :pointer,
           :weights, :pointer,
           :num_values_and_weights, :uint
  end

  AnimBehaviour = enum(:anim_behavior, [
    :DEFAULT,
    :CONSTANT,
    :LINEAR,
    :REPEAT
  ])

  class NodeAnim < FFI::Struct
    layout :node_name, String,
           :num_position_keys, :uint,
           :position_keys, :pointer, #VectorKey
           :num_rotation_keys, :uint,
           :rotation_keys, :pointer, #QuatKey
           :num_scaling_keys, :uint,
           :scaling_keys, :pointer, #VectorKey
           :pre_state, AnimBehaviour,
           :post_state, AnimBehaviour
  end

  class MeshAnim < FFI::Struct
    layout :name, String,
           :num_keys, :uint,
           :keys, :pointer #MeshKey
  end

  class MeshMorphAnim < FFI::Struct
    layout :name, String,
           :num_keys, :uint,
           :keys, :pointer #MeshMorphKey
  end

  class Animation < FFI::Struct
    layout :name, String,
           :duration, :double,
           :ticks_per_second, :double,
           :num_channels, :uint,
           :channels, :pointer, #NodeAnim*
           :num_mesh_channels, :uint,
           :mesh_channels, :pointer, #MeshAnim*
           :num_morph_mesh_channels, :uint,
           :morph_mesh_channels, :pointer #MeshMorphAnim*
  end

end
