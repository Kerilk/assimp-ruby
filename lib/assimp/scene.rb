module Assimp

  class Node < FFI::Struct
    extend StructAccessors

    layout :name, String,
           :transformation, Matrix4x4,
           :parent, :pointer, #Node or null,
           :num_children, :uint,
           :children, :pointer, #Node*[num_chidren]
           :num_meshes, :uint,
           :meshes, :pointer, #uint[num_meshes]
           :meta_data, Metadata.ptr

    struct_attr_reader :name,
                       :transformation,
                       :num_children,
                       :num_meshes,
                       :meta_data

    struct_array_attr_reader [:children, Node]

    def meshes
      p = self[:meshes]
      return [] if p.null? || num_meshes == 0
      p.read_array_of_uint(num_meshes)
    end

    def parent
      ptr = self[:parent]
      return nil if ptr.null?
      Node::new(ptr)
    end

    def each_node(&block)
      if block then
        block.call self
        children.each { |c|
          c.each_node(&block)
        }
        return self
      else
        to_enum(:each_node)
      end
    end

  end

  SceneFlags = bitmask(:scene_flags, [
    :INCOMPLETE,
    :VALIDATED,
    :VALIDATION_WARNING,
    :NON_VERBOSE_FORMAT,
    :FLAGS_TERRAIN,
    :FLAGS_ALLOW_SHARED
  ])

  class Scene < FFI::Struct
    extend StructAccessors

    layout :flags, SceneFlags,
           :root_node, Node.ptr,
           :num_meshes, :uint,
           :meshes, :pointer, #Mesh*[num_meshes]
           :num_materials, :uint,
           :materials, :pointer, #Material*[num_materials]
           :num_animations, :uint,
           :animations, :pointer, #Animation*[num_animations]
           :num_textures, :uint,
           :textures, :pointer, #Texture*[num_textures]
           :num_lights, :uint,
           :lights, :pointer, #Light*[num_lights]
           :num_cameras, :uint,
           :cameras, :pointer #Camera*[num_cameras]

    struct_attr_reader :flags,
                       :root_node,
                       :num_meshes,
                       :num_materials,
                       :num_animations,
                       :num_textures,
                       :num_lights,
                       :num_cameras

    struct_array_attr_reader [:meshes, Mesh],
                             [:materials, Material],
                             [:animations, Animation],
                             [:textures, Texture],
                             [:lights, Light],
                             [:cameras, Camera]

    def each_node(&block)
      if block then
        node = root_node
        node.each_node(&block)
        return self
      else
        to_enum(:each_obj)
      end
    end

  end

end
