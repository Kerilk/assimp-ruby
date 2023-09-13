module Assimp

  class Vector2D < FFI::Struct
    extend StructAccessors
    layout :x, :ai_real,
           :y, :ai_real
    struct_attr_accessor :x, :y

    def to_s
      "<#{x}, #{y}>"
    end
  end

end
