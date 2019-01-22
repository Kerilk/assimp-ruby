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
    struct_attr_accessor :translation,
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
  MATKEY_MAPPINGMODE_W = "$tex.mapmodew"
  MATKEY_TEXMAP_AXIS   = "$tex.mapaxis"
  MATKEY_UVTRANSFORM   = "$tex.uvtrafo"
  MATKEY_TEXFLAGS      = "$tex.flags"

  class MaterialProperty < FFI::Struct
    TEX_PROPERTIES = [ MATKEY_TEXTURE,
                       MATKEY_UVWSRC,
                       MATKEY_TEXOP,
                       MATKEY_MAPPING,
                       MATKEY_TEXBLEND,
                       MATKEY_MAPPINGMODE_U,
                       MATKEY_MAPPINGMODE_V,
                       MATKEY_MAPPINGMODE_W,
                       MATKEY_TEXMAP_AXIS,
                       MATKEY_UVTRANSFORM,
                       MATKEY_TEXFLAGS ]
    COLOR_PROPERTIES = [ MATKEY_COLOR_DIFFUSE,
                         MATKEY_COLOR_AMBIENT,
                         MATKEY_COLOR_SPECULAR,
                         MATKEY_COLOR_EMISSIVE,
                         MATKEY_COLOR_TRANSPARENT,
                         MATKEY_COLOR_REFLECTIVE ]
    STRING_PROPERTIES = [ MATKEY_NAME,
                          MATKEY_GLOBAL_BACKGROUND_IMAGE,
                          MATKEY_TEXTURE ]
    BOOL_PROPERTIES = [ MATKEY_TWOSIDED, MATKEY_ENABLE_WIREFRAME ]
    INTEGER_PROPERTIES = BOOL_PROPERTIES +
                       [ MATKEY_UVWSRC,
                         MATKEY_SHADING_MODEL,
                         MATKEY_MAPPINGMODE_U,
                         MATKEY_MAPPINGMODE_V,
                         MATKEY_MAPPINGMODE_W,
                         MATKEY_BLEND_FUNC,
                         MATKEY_TEXFLAGS,
                         MATKEY_MAPPING,
                         MATKEY_TEXOP ]
    FLOAT_PROPERTIES = COLOR_PROPERTIES +
                     [ MATKEY_UVTRANSFORM,
                       MATKEY_TEXBLEND,
                       MATKEY_OPACITY,
                       MATKEY_SHININESS,
                       MATKEY_REFLECTIVITY,
                       MATKEY_REFRACTI,
                       MATKEY_SHININESS_STRENGTH,
                       MATKEY_BUMPSCALING,
                       MATKEY_TEXMAP_AXIS ]

    extend StructAccessors
    layout :key, String,
           :semantic, TextureType,
           :index, :uint,
           :data_length, :uint,
           :type, PropertyTypeInfo,
           :data, :pointer #byte[data_length]
    struct_attr_accessor :key,
                         :semantic,
                         :index,
                         :data_length,
                         :type

    @__has_ref = true

    def set_property(key, val, semantic: 0, index: 0, type: nil)
      if type
        self.type = type
      else
        case key
        when *STRING_PROPERTIES
          self.type = :String
        when *INTEGER_PROPERTIES
          self.type = :Integer
        when *FLOAT_PROPERTIES
          if ENV["ASSIMP_DOUBLE_PRECISION"]
            self.type = :Double
          else
            self.type = :Float
          end
        else
          raise ArgumentError::new("Could not determine property type!")
        end
      end
      if semantic == 0 && TEX_PROPERTIES.include?(key)
        raise ArgumentError::new("Missing semantic for texture property!")
      elsif semantic != 0 && ! TEX_PROPERTIES.include?(key)
        raise ArgumentError::new("Semantic given for non texture property!")
      else
        self.semantic = semantic
      end
      if index != 0 && ! TEX_PROPERTIES.include?(key)
        raise ArgumentError::new("Index given for non texture property!")
      else
        self.index = index
      end
      self.key = key
      self.data = val
      self
    end

    def data=(val)
      ptr = nil
      case type
      when :String
        length = val.bytesize
        ptr = FFI::MemoryPointer::new(length+4+1)
        ptr.write_uint(length)
        ptr.put_string(4, val)
      when :Integer
        if val.kind_of? Array
          ptr = FFI::MemoryPointer::new(:int, val.length)
          ptr.write_array_of_int(val)
        else
          i = nil
          case key
          when *BOOL_PROPERTIES
            if val.nil? || val == false || val == 0
              i = ASSIMP::FALSE
            else
              i = ASSIMP::TRUE
            end
          when MATKEY_SHADING_MODEL
            i = ShadingMode.to_native(val, nil)
          when MATKEY_MAPPINGMODE_U, MATKEY_MAPPINGMODE_V, MATKEY_MAPPINGMODE_W
            i = TextureMapMode.to_native(val, nil)
          when MATKEY_BLEND_FUNC
            i = BlendMode.to_native(val, nil)
          when MATKEY_TEXFLAGS
            i = TextureFlags.to_native(val, nil)
          when MATKEY_MAPPING
            i = TextureMapping.to_native(val, nil)
          when MATKEY_TEXOP
            i = TextureOp.to_native(val, nil)
          else
            i = val
          end
          ptr = FFI::MemoryPointer::new(:int)
          ptr.write_int(i)
        end
      when :Float
        if val.kind_of? Array
          ptr = FFI::MemoryPointer::new(:float, val.length)
          ptr.write_array_of_float(val)
        elsif val.kind_of? FFI::Struct
          ptr = FFI::MemoryPointer::new(val.class.size)
          ptr.write_array_of_uint8(val.pointer.read_array_of_uint8(val.class.size))
        else
          ptr.write_float(val)
        end
      when :Double
        if val.kind_of? Array
          ptr = FFI::MemoryPointer::new(:double, val.length)
          ptr.write_array_of_double(val)
        elsif val.kind_of? FFI::Struct
          ptr = FFI::MemoryPointer::new(val.class.size)
          ptr.write_array_of_uint8(val.pointer.read_array_of_uint8(val.class.size))
        else
          ptr.write_double(val)
        end
      when :Buffer
        if val.kind_of? FFI::Pointer
          ptr = FFI::MemoryPointer::new(val.size)
          ptr.write_array_of_uint8(val.pointer.read_array_of_uint8(val.size))
        else
          ptr = FFI::MemoryPointer.from_string(val)
        end
      else
        raise ArgumentError::new("Invalid type: #{type.inspect}!")
      end
      @data = ptr
      self[:data] = ptr
      self.data_length = (ptr ? ptr.size : 0)
      val
    end

    def data
      case type
      when :String
        length = self[:data].read_uint
        self[:data].get_string(4, length)
      when :Integer
        if data_length == 4
          i = self[:data].read_int
          case key
          when *BOOL_PROPERTIES
            i != 0
          when MATKEY_SHADING_MODEL
            ShadingMode[i]
          when MATKEY_MAPPINGMODE_U, MATKEY_MAPPINGMODE_V, MATKEY_MAPPINGMODE_W
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
          elsif key == MATKEY_TEXMAP_AXIS && data_length == Vector3D.size
            Vector3D.new(self[:data])
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
          elsif key == MATKEY_TEXMAP_AXIS && data_length == Vector3D.size
            Vector3D.new(self[:data])
          elsif key == MATKEY_UVTRANSFORM && data_length == UVTransform.size
            UVTransform.new(self[:data])
          else
            self[:data].read_array_of_double(data_length/8)
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
      "#{key}: #{data}"
    end
  end

  class Material < FFI::Struct
    extend StructAccessors
    layout :properties, :pointer, #MaterialProperty*[num_properties]
           :num_properties, :uint,
           :num_allocated, :uint
    struct_attr_accessor :num_properties,
                         :num_allocated
    struct_ref_array_attr_accessor [:properties, MaterialProperty]

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
