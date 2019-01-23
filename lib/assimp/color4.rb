module Assimp

  class Color4D < FFI::Struct
    extend StructAccessors
    layout :r, :ai_real,
           :g, :ai_real,
           :b, :ai_real,
           :a, :ai_real
    struct_attr_accessor :r, :g, :b, :a

    def set(r, g, b, a)
      self.r = r
      self.g = g
      self.b = b
      self.a = a
      self
    end

    def to_s
      "[#{r}, #{g}, #{b}, #{a}]"
    end
  end

end
