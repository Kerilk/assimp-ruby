module Assimp

  class Vector2D < FFI::Struct
    layout :x, :ai_real,
           :y, :ai_real
  end

end
