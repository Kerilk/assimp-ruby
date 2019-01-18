module Assimp

  class Vector3D < FFI::Struct
    extend StructAccessors
    layout :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real

    struct_attr_reader :x, :y, :z

    def to_s
      "<#{x}, #{y}, #{z}>"
    end
  end

end
