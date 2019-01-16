module Assimp

  class Vector3D < FFI::Struct
    layout :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real
  end

end
