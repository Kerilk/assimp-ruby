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
    extend StructAccessors
    pack 1
    layout :translation, Vector2D,
           :scaling, Vector2D,
           :rotation, :ai_real
    struct_attr_reader :translation,
                       :scaling,
                       :rotation
  end

  PropertyTypeInfo = enum(:property_type_info, [
    :Float, 1,
    :Double,
    :String,
    :Integer,
    :Buffer
  ])

  MATKEY_NAME                    = "?mat.name"
  MATKEY_TWOSIDED                = "$mat.twosided"
  MATKEY_SHADING_MODEL           = "$mat.shadingm"
  MATKEY_ENABLE_WIREFRAME        = "$mat.wireframe"
  MATKEY_BLEND_FUNC              = "$mat.blend"
  MATKEY_OPACITY                 = "$mat.opacity"
  MATKEY_BUMPSCALING             = "$mat.bumpscaling"
  MATKEY_SHININESS               = "$mat.shininess"
  MATKEY_REFLECTIVITY            = "$mat.reflectivity"
  MATKEY_SHININESS_STRENGTH      = "$mat.shinpercent"
  MATKEY_REFRACTI                = "$mat.refracti"
  MATKEY_COLOR_DIFFUSE           = "$clr.diffuse"
  MATKEY_COLOR_AMBIENT           = "$clr.ambient"
  MATKEY_COLOR_SPECULAR          = "$clr.specular"
  MATKEY_COLOR_EMISSIVE          = "$clr.emissive"
  MATKEY_COLOR_TRANSPARENT       = "$clr.transparent"
  MATKEY_COLOR_REFLECTIVE        = "$clr.reflective"
  MATKEY_GLOBAL_BACKGROUND_IMAGE = "?bg.global"
  MATKEY_TEXTURE       = "$tex.file"
  MATKEY_UVWSRC        = "$tex.uvwsrc"
  MATKEY_TEXOP         = "$tex.op"
  MATKEY_MAPPING       = "$tex.mapping"
  MATKEY_TEXBLEND      = "$tex.blend"
  MATKEY_MAPPINGMODE_U = "$tex.mapmodeu"
  MATKEY_MAPPINGMODE_V = "$tex.mapmodev"
  MATKEY_TEXMAP_AXIS   = "$tex.mapaxis"
  MATKEY_UVTRANSFORM   = "$tex.uvtrafo"
  MATKEY_TEXFLAGS      = "$tex.flags"

  class MaterialProperty < FFI::Struct
    extend StructAccessors
    layout :key, String,
           :semantic, TextureType,
           :index, :uint,
           :data_length, :uint,
           :type, PropertyTypeInfo,
           :data, :pointer #byte[data_length]
    struct_attr_reader :key
    struct_attr_accessor :semantic,
                         :index,
                         :data_length,
                         :type
    def data
      key = self[:key].to_s
      case type
      when :String
        length = self[:data].read_uint 
        self[:data].get_string(4, length)
      when :Integer
        if data_length == 4
          i = self[:data].read_int
          case key
          when MATKEY_TWOSIDED, MATKEY_ENABLE_WIREFRAME, MATKEY_UVWSRC
            i != 0
          when MATKEY_SHADING_MODEL
            ShadingMode[i]
          when MATKEY_MAPPINGMODE_U, MATKEY_MAPPINGMODE_V
            TextureMapMode[i]
          when MATKEY_BLEND_FUNC
            BlendMode[i]
          when MATKEY_TEXFLAGS
            TextureFlags[i]
          when MATKEY_MAPPING
            TextureMapping[i]
          when MATKEY_TEXOP
            TextureOp[i]
          else
            i
          end
        elsif data_length > 4
          self[:data].read_array_of_int(data_length/4)
        else
          nil
        end
      when :Float
        if data_length == 4
          self[:data].read_float
        elsif data_length > 4
          if key.match("\\$clr\\.") && data_length == Color4D.size
            Color4D.new(self[:data])
          elsif key == MATKEY_UVTRANSFORM && data_length == UVTransform.size
            UVTransform.new(self[:data])
          else
            self[:data].read_array_of_float(data_length/4)
          end
        else
          nil
        end
      when :Double
        if data_length == 8
          self[:data].read_double
        elsif data_length > 8
          if key.match("\\$clr\\.") && data_length == Color4D.size
            Color4D.new(self[:data])
          elsif key == MATKEY_UVTRANSFORM && data_length == UVTransform.size
            UVTransform.new(self[:data])
          else
            self[:data].read_array_of_double(data_length/4)
          end
        else
          nil
        end
      when :Buffer
        self[:data].slice(0, data_length)
      else
        raise "Invalid type: #{type.inspect}!"
      end
    end

    def to_s
      "#{self[:key].to_s}: #{data}"
    end
  end

  class Material < FFI::Struct
    extend StructAccessors
    layout :properties, :pointer, #MaterialProperty*[num_properties]
           :num_properties, :uint,
           :num_allocated, :uint
    struct_attr_accessor :num_properties,
                         :num_allocated
    struct_ref_array_attr_reader [:properties, MaterialProperty]

    def property(key, type, index)
      ptr = FFI::MemoryPointer::new(:pointer)
      res = Assimp::aiGetMaterialProperty(self, key, type, index, ptr)
      raise "get_material_property error!" unless res == :SUCCESS
      new_ptr = ptr.read_pointer
      return nil if new_ptr.null?
      MaterialProperty::new(new_ptr) 
    end

  end

  attach_function :aiGetMaterialProperty,
                  [Material.ptr, :string, :uint, :uint, :pointer ], Return


  attach_function :aiGetMaterialFloatArray,
                  [Material.ptr, :string, :uint, :uint, :pointer, :pointer], Return

  attach_function :aiGetMaterialIntegerArray,
                  [Material.ptr, :string, :uint, :uint, :pointer, :pointer], Return

  attach_function :aiGetMaterialColor,
                  [Material.ptr, :string, :uint, :uint, Color4D.ptr], Return

  attach_function :aiGetMaterialUVTransform,
                  [Material.ptr, :string, :uint, :uint, UVTransform.ptr], Return

  attach_function :aiGetMaterialString,
                  [Material.ptr, :string, :uint, :uint, String.ptr], Return

  attach_function :aiGetMaterialTextureCount,
                  [Material.ptr, TextureType], :uint

  attach_function :aiGetMaterialTexture,
                  [Material.ptr, TextureType, :uint, String.ptr, :pointer, :uint, :pointer, :pointer, :pointer, :pointer], Return

end
