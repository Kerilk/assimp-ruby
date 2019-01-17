module Assimp

  MAX_FACE_INDICES = 0x7fff
  MAX_BONE_WEIGHTS = 0x7fffffff
  MAX_VERTICES = 0x7fffffff
  MAX_FACES = 0x7fffffff
  MAX_NUMBER_OF_COLOR_SETS = 0x8
  MAX_NUMBER_OF_TEXTURECOORDS = 0x8

  class Face < FFI::Struct
    layout :num_indices, :uint,
           :indices, :uint
  end

  class VertexWeight < FFI::Struct
    layout :vertex_id, :uint,
           :weight, :float
  end

  class Bone < FFI::Struct
    layout :name, String,
           :num_weights, :uint,
           :weights, :pointer, #VertexWeight[num_weights]
           :offset_matrix, Matrix4x4
  end

  PrimitiveType = bitmask(:primitive_type, [
    :POINT,
    :LINE,
    :TRIANGLE,
    :POLYGON
  ])

  class AnimMesh < FFI::Struct
    layout :vertices, :pointer, #Vector3D[]
           :normals, :pointer, #Vector3D[]
           :tangeants, :pointer, #Vector3D[]
           :bitangents, :pointer, #Vector3D[]
           :colors, [Color4D, MAX_NUMBER_OF_COLOR_SETS],
           :texture_coords, [Color4D, MAX_NUMBER_OF_TEXTURECOORDS],
           :num_vertices, :uint,
           :weight, :float
  end

  MorphingMethod = enum(:morphing_method, [
    :VERTEX_BLEND, 1,
    :MORPH_NORMALIZED, 2,
    :MORPH_RELATIVE, 3
  ])

  class Mesh < FFI::Struct
    layout :primitive_types, PrimitiveType,
           :num_vertices, :uint,
           :num_faces, :uint,
           :vertices, :pointer, #Vector3D[num_vertices]
           :normals, :pointer, #Vector3D[num_vertices]
           :tangents, :pointer, #Vector3D[num_vertices]
           :bitangents, :pointer, #Vector3D[num_vertices]
           :colors, [Color4D, MAX_NUMBER_OF_COLOR_SETS],
           :texture_coords, [Color4D, MAX_NUMBER_OF_TEXTURECOORDS],
           :num_uv_components, [:uint, MAX_NUMBER_OF_TEXTURECOORDS],
           :faces, :pointer, #Face[num_faces]
           :num_bones, :uint,
           :bones, :pointer, #Bone*[num_bones]
           :material_index, :uint,
           :name, String,
           :num_anim_meshes, :uint,
           :anim_meshes, :pointer, #AnimMesh*[num_anim_meshes]
           :method, MorphingMethod
  end
end
