module Assimp

  class Texel < FFI::Struct
    pack 1
    layout :b, :uchar,
           :g, :uchar,
           :r, :uchar,
           :a, :uchar
  end

  class Texture < FFI::Struct
    layout :width, :uint,
           :height, :uint,
           :format_hint, [:char, 9],
           :data, :pointer #Texel[width*height]
  end

end
