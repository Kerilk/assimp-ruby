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

    struct_array_attr_accessor [:indices, :uint]

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

    struct_array_attr_accessor [:weights, VertexWeight]

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

    struct_array_attr_accessor [:vertices, Vector3D],
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

    def set_colors(index, colors)
      @colors = [nil]*MAX_NUMBER_OF_COLOR_SETS unless @colors
      raise "Invalid colors index #{index}!" if index < 0 || index >= MAX_NUMBER_OF_COLOR_SETS
      unless colors && colors.length > 0
        @colors[index] = nil
        return self
      end
      raise "Invalid colors count: #{colors.length}!" if num_vertices != colors.length
      ptr = FFI::MemoryPointer::new(Assimp::Color4D, num_vertices)
      s = Assimp::Color4D.size
      colors.each_with_index { |v, i|
        ptr.put_array_of_uint8(i*s, v.pointer.read_array_of_uint8(s))
      }
      @colors[index] = ptr
      self
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

    def set_texture_coords(index, uvs)
      @texture_coords = [nil]*MAX_NUMBER_OF_TEXTURECOORDS unless @texture_coords
      raise "Invalid texture_coords index #{index}!" if index < 0 || index >= MAX_NUMBER_OF_TEXTURECOORDS
      unless uvs && uvs.length > 0
        @texture_coords[index] = nil
        return self
      end
      raise "Invalid texture_coords count: #{uvs.length}!" if num_vertices != uvs.length
      ptr = FFI::MemoryPointer::new(Assimp::Vector3D, num_vertices)
      s = Assimp::Vector3D.size
      uvs.each_with_index { |v, i|
        ptr.put_array_of_uint8(i*s, v.pointer.read_array_of_uint8(s))
      }
      @texture_coords[index] = ptr
      self
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
                         :num_uv_components,
                         :num_bones,
                         :material_index,
                         :num_anim_meshes,
                         :method

    struct_array_attr_accessor [:vertices, Vector3D],
                               [:normals, Vector3D, :num_vertices],
                               [:tangents, Vector3D, :num_vertices],
                               [:bitangents, Vector3D, :num_vertices],
                               [:faces, Face]

    struct_ref_array_attr_accessor [:bones, Bone],
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

    def set_colors(index, colors)
      @colors = [nil]*MAX_NUMBER_OF_COLOR_SETS unless @colors
      raise "Invalid colors index #{index}!" if index < 0 || index >= MAX_NUMBER_OF_COLOR_SETS
      unless colors && colors.length > 0
        @colors[index] = nil
        return self
      end
      raise "Invalid colors count: #{colors.length}!" if num_vertices != colors.length
      ptr = FFI::MemoryPointer::new(Assimp::Color4D, num_vertices)
      s = Assimp::Color4D.size
      colors.each_with_index { |v, i|
        ptr.put_array_of_uint8(i*s, v.pointer.read_array_of_uint8(s))
      }
      @colors[index] = ptr
      self[:colors][index] = ptr
      self
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

    def set_texture_coords(index, uvs)
      @texture_coords = [nil]*MAX_NUMBER_OF_TEXTURECOORDS unless @texture_coords
      raise "Invalid texture_coords index #{index}!" if index < 0 || index >= MAX_NUMBER_OF_TEXTURECOORDS
      unless uvs && uvs.length > 0
        @texture_coords[index] = nil
        return self
      end
      raise "Invalid texture_coords count: #{uvs.length}!" if num_vertices != uvs.length
      ptr = FFI::MemoryPointer::new(Assimp::Vector3D, num_vertices)
      s = Assimp::Vector3D.size
      uvs.each_with_index { |v, i|
        ptr.put_array_of_uint8(i*s, v.pointer.read_array_of_uint8(s))
      }
      @texture_coords[index] = ptr
      self[:texture_coords][index] = ptr
      self
    end

  end
end
