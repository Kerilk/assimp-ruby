module Assimp

  class Color4D < FFI::Struct
    layout :r, :ai_real,
           :g, :ai_real,
           :b, :ai_real,
           :a, :ai_real
  end

end
