module Assimp

  TextureOp = enum(:texture_op, [
    :Multiply,
    :Add,
    :Subtract,
    :Divide,
    :SmoothAdd,
    :SignedAdd
  ])

  TextureMapMode = enum(:texture_map_mode, [
    :Wrap,
    :Clamp,
    :Mirror,
    :Decal
  ])

  TextureMapping = enum(:texture_mapping, [
    :UV,
    :SPHERE,
    :CYLINDER,
    :BOX,
    :PLANE,
    :OTHER
  ])

  TextureType = enum(:texture_type, [
    :NONE,
    :DIFFUSE,
    :SPECULAR,
    :AMBIENT,
    :EMISSIVE,
    :HEIGHT,
    :NORMALS,
    :SHININESS,
    :OPACITY,
    :DISPLACEMENT,
    :LIGHTMAP,
    :REFLECTION,
    :UNKNOWN
  ])

  ShadingMode = enum(:shading_mode, [
    :Flat, 1,
    :Gouraud,
    :Phong,
    :Blinn,
    :Toon,
    :OrenNayar,
    :Minnaert,
    :CookTorrance,
    :NoShading,
    :Fresnel
  ])

  TextureFlags = bitmask(:texture_flags, [
    :Invert,
    :UseAlpha,
    :IgnoreAlpha
  ])

  BlendMode = enum(:blend_mode, [
    :Default,
    :Additive
  ])

  class UVTransform < FFI::Struct
    pack 1
    layout :translation, Vector2D,
           :scaling, Vector2D,
           :rotation, :ai_real
  end

  PropertyTypeInfo = enum(:property_type_info, [
    :Float, 1,
    :Double,
    :String,
    :Integer,
    :Buffer
  ])

  class MaterialProperty < FFI::Struct
    layout :key, String,
           :semantic, :uint,
           :index, :uint,
           :data_length, :uint,
           :type, PropertyTypeInfo,
           :data, :pointer #byte[data_length]
  end

  class Material < FFI::Struct
    layout :properties, :pointer, #MaterialProperty*
           :num_properties, :uint,
           :num_allocated, :uint

    def property(key, type, index)
      ptr = FFI::MemoryPointer::new(:pointer)
      res = Assimp::get_material_property(self, key, type, index, ptr)
      raise "get_material_property error!" unless res == :SUCCESS
      new_ptr = ptr.read_pointer
      return nil if new_ptr.null?
      MaterialProperty::new(new_ptr) 
    end

  end

  attach_function :get_material_property, :aiGetMaterialProperty,
                  [Material.ptr, :string, :uint, :uint, :pointer ], Return


  attach_function :get_material_float_array, :aiGetMaterialFloatArray,
                  [Material.ptr, :string, :uint, :uint, :pointer, :pointer], Return

  attach_function :get_material_integer_array, :aiGetMaterialIntegerArray,
                  [Material.ptr, :string, :uint, :uint, :pointer, :pointer], Return

  attach_function :get_material_color, :aiGetMaterialColor,
                  [Material.ptr, :string, :uint, :uint, Color4D.ptr], Return

  attach_function :get_material_uv_transform, :aiGetMaterialUVTransform,
                  [Material.ptr, :string, :uint, :uint, UVTransform.ptr], Return

  attach_function :get_material_string, :aiGetMaterialString,
                  [Material.ptr, :string, :uint, :uint, String.ptr], Return

  attach_function :get_material_texture_count, :aiGetMaterialTextureCount,
                  [Material.ptr, TextureType], :uint

  attach_function :get_material_texture, :aiGetMaterialTexture,
                  [Material.ptr, TextureType, :uint, String.ptr, :pointer, :uint, :pointer, :pointer, :pointer, :pointer], Return

end
