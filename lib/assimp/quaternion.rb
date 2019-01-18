module Assimp

  class Quaternion < FFI::Struct
    extend StructAccessors
    layout :w, :ai_real,
           :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real
    struct_attr_reader :w, :x, :y, :z

    def to_s
      "{#{w}, #{x}, #{y}, #{z}}"
    end
  end

end
