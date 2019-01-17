module Assimp

  class Node < FFI::Struct
    layout :name, String,
           :transformation, Matrix4x4,
           :parent, Node.ptr,
           :num_children, :uint,
           :children, :pointer, #Node*[num_chidren]
           :num_meshes, :uint,
           :meshes, :pointer, #uint[num_meshes]
           :meta_data, Metadata.ptr
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
  end

end
