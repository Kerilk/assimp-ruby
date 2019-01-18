module Assimp

  class Texel < FFI::Struct
    extend StructAccessors
    pack 1
    layout :b, :uchar,
           :g, :uchar,
           :r, :uchar,
           :a, :uchar
    struct_attr_reader :b, :g, :r, :a
    def to_s
      "[#{r}, #{g}, #{b}, #{a}]"
    end
  end

  class Texture < FFI::Struct
    extend StructAccessors
    layout :width, :uint,
           :height, :uint,
           :format_hint, [:char, 9],
           :data, :pointer #Texel[width*height]
    struct_attr_reader :width,
                       :height

    def format_hint
      self[:format_hint].to_a.pack("U*")
    end

  end

end
