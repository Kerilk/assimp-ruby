module Assimp

  MAX_FACE_INDICES = 0x7fff
  MAX_BONE_WEIGHTS = 0x7fffffff
  MAX_VERTICES = 0x7fffffff
  MAX_FACES = 0x7fffffff
  MAX_NUMBER_OF_COLOR_SETS = 0x8
  MAX_NUMBER_OF_TEXTURECOORDS = 0x8

  class Face < FFI::Struct
    extend StructAccessors
    layout :num_indices, :uint,
           :indices, :pointer #:uint[num_indices]

    struct_attr_accessor :num_indices

    struct_array_attr_reader [:indices, :uint]

  end

  class VertexWeight < FFI::Struct
    extend StructAccessors

    layout :vertex_id, :uint,
           :weight, :float

    struct_attr_accessor :vertex_id,
                         :weight
  end

  class Bone < FFI::Struct
    extend StructAccessors

    layout :name, String,
           :num_weights, :uint,
           :weights, :pointer, #VertexWeight[num_weights]
           :offset_matrix, Matrix4x4

    struct_attr_accessor :name,
                         :num_weights,
                         :offset_matrix

    struct_array_attr_reader [:weights, VertexWeight]

  end

  PrimitiveType = bitmask(:primitive_type, [
    :POINT,
    :LINE,
    :TRIANGLE,
    :POLYGON
  ])

  class AnimMesh < FFI::Struct
    extend StructAccessors

    layout :vertices, :pointer, #Vector3D[]
           :normals, :pointer, #Vector3D[]
           :tangents, :pointer, #Vector3D[]
           :bitangents, :pointer, #Vector3D[]
           :colors, [:pointer, MAX_NUMBER_OF_COLOR_SETS], #Color4D[num_vertices]
           :texture_coords, [:pointer, MAX_NUMBER_OF_TEXTURECOORDS], #Vector3D[num_vertices]
           :num_vertices, :uint,
           :weight, :float

    struct_attr_accessor :num_vertices,
                         :weight

    struct_array_attr_reader [:vertices, Vector3D],
                             [:normals, Vector3D, :num_vertices],
                             [:tangents, Vector3D, :num_vertices],
                             [:bitangents, Vector3D, :num_vertices]

    def colors
      cs = self[:colors].to_a
      cs.collect { |c_ptr|
        if c_ptr.null?
          nil
        else
          s = Color4D.size
          num_vertices.times.collect { |i|
            Color4D::new(c_ptr+i*s)
          }
        end
      }
    end

    def texture_coords
      tcs = self[:texture_coords].to_a
      tcs.collect { |tc_ptr|
        if tc_ptr.null?
          nil
        else
          s = Vector3D.size
          num_vertices.times.collect { |i|
            Vector3D::new(tc_ptr+i*s)
          }
        end
      }
    end

  end

  MorphingMethod = enum(:morphing_method, [
    :VERTEX_BLEND, 1,
    :MORPH_NORMALIZED, 2,
    :MORPH_RELATIVE, 3
  ])

  class Mesh < FFI::Struct
    extend StructAccessors

    layout :primitive_types, PrimitiveType,
           :num_vertices, :uint,
           :num_faces, :uint,
           :vertices, :pointer, #Vector3D[num_vertices]
           :normals, :pointer, #Vector3D[num_vertices]
           :tangents, :pointer, #Vector3D[num_vertices]
           :bitangents, :pointer, #Vector3D[num_vertices]
           :colors, [:pointer, MAX_NUMBER_OF_COLOR_SETS], #Color4D[num_vertices]
           :texture_coords, [:pointer, MAX_NUMBER_OF_TEXTURECOORDS], #Vector3D[num_vertices]
           :num_uv_components, [:uint, MAX_NUMBER_OF_TEXTURECOORDS],
           :faces, :pointer, #Face[num_faces]
           :num_bones, :uint,
           :bones, :pointer, #Bone*[num_bones]
           :material_index, :uint,
           :name, String,
           :num_anim_meshes, :uint,
           :anim_meshes, :pointer, #AnimMesh*[num_anim_meshes]
           :method, MorphingMethod

    struct_attr_accessor :name,
                         :primitive_types,
                         :num_vertices,
                         :num_faces,
                         :num_bones,
                         :material_index,
                         :num_anim_meshes,
                         :method

    struct_array_attr_reader [:vertices, Vector3D],
                             [:normals, Vector3D, :num_vertices],
                             [:tangents, Vector3D, :num_vertices],
                             [:bitangents, Vector3D, :num_vertices],
                             [:faces, Face]

    struct_ref_array_attr_reader [:bones, Bone],
                                 [:anim_meshes, AnimMesh]

    def colors
      cs = self[:colors].to_a
      cs.collect { |c_ptr|
        if c_ptr.null?
          nil
        else
          s = Color4D.size
          num_vertices.times.collect { |i|
            Color4D::new(c_ptr+i*s)
          }
        end
      }
    end

    def texture_coords
      tcs = self[:texture_coords].to_a
      tcs.collect { |tc_ptr|
        if tc_ptr.null?
          nil
        else
          s = Vector3D.size
          num_vertices.times.collect { |i|
            Vector3D::new(tc_ptr+i*s)
          }
        end
      }
    end

    def num_uv_components
      self[:num_uv_components].to_a
    end

  end
end
